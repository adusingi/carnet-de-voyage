# Controller for managing travel maps and their associated places.
#
# Handles CRUD operations for maps, including:
# - Creating maps from natural language travel notes (AI-powered extraction)
# - Displaying maps with interactive visualizations
# - Editing and updating map content
# - Authorization for public/private/shared maps
# - PDF export functionality
class MapsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :new]
  before_action :set_map, only: [:show, :edit, :update, :destroy]
  before_action :authorize_map_view, only: [:show]
  before_action :authorize_map, only: [:edit, :update, :destroy]

  # Display list of maps for signed-in users only
  def index
    @maps = current_user.maps.recent
  end

  # Display a single map with its places and interactive visualization
  #
  # Supports both HTML and PDF formats
  def show
    # @map is set by before_action
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MapPdfGenerator.new(@map).generate
        send_data pdf.render,
                  filename: "#{@map.title.parameterize}-map.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  # Show form for creating a new map
  #
  # Allows non-authenticated users to see the form
  # Authentication check happens on create
  def new
    # Check if user is signed in and has reached their limit
    if user_signed_in? && !current_user.can_create_map?
      redirect_to maps_path, alert: "You've reached your map limit. Upgrade to create more maps."
      return
    end

    @map = Map.new

    # Restore pending map data if user just signed up
    if session[:pending_map_data].present?
      @map.assign_attributes(session[:pending_map_data])
    end
  end

  # Create a new map from travel notes
  #
  # Requires authentication - redirects to sign up if user is not signed in
  # Uses AI (PlaceExtractor) to extract destination and places from text,
  # then geocodes places to coordinates using PlaceGeocoder
  def create
    # Redirect to sign up if user is not signed in
    unless user_signed_in?
      # Store the form data in session so we can restore it after sign up
      session[:pending_map_data] = map_params.to_h
      redirect_to new_user_registration_path, alert: "Please sign up or log in to create your map."
      return
    end

    unless current_user.can_create_map?
      redirect_to maps_path, alert: "You've reached your map limit. Upgrade to create more maps."
      return
    end

    @map = current_user.maps.build(map_params)

    # Extract places from text if provided
    if @map.original_text.present?
      extraction_result = PlaceExtractor.new(@map.original_text).extract

      if extraction_result[:success]
        @map.destination = extraction_result[:destination]
        @map.processed_text = extraction_result[:places].to_json

        # Geocode places
        geocoded_places = PlaceGeocoder.new(
          extraction_result[:places],
          extraction_result[:destination]
        ).geocode

        # Create place records
        geocoded_places.each_with_index do |place_data, index|
          @map.places.build(
            name: place_data[:name],
            latitude: place_data[:latitude],
            longitude: place_data[:longitude],
            address: place_data[:address],
            place_type: place_data[:type],
            context: place_data[:context],
            position: index
          )
        end
      end
    end

    if @map.save
      # Clear the pending map data from session
      session.delete(:pending_map_data)
      redirect_to @map, notice: "Map was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Show form for editing an existing map
  def edit
    # @map is set by before_action
  end

  # Update an existing map
  #
  # If original_text changes, re-extracts and re-geocodes all places
  def update
    # Store original text to check if it changed
    original_text = @map.original_text

    # Update the map with new params
    @map.assign_attributes(map_params)

    # If original_text changed, re-extract and geocode places
    if @map.original_text_changed? && @map.original_text.present?
      # Delete existing places
      @map.places.destroy_all

      # Extract places from new text
      extraction_result = PlaceExtractor.new(@map.original_text).extract

      if extraction_result[:success]
        @map.destination = extraction_result[:destination]
        @map.processed_text = extraction_result[:places].to_json

        # Geocode places
        geocoded_places = PlaceGeocoder.new(
          extraction_result[:places],
          extraction_result[:destination]
        ).geocode

        # Create new place records
        geocoded_places.each_with_index do |place_data, index|
          @map.places.build(
            name: place_data[:name],
            latitude: place_data[:latitude],
            longitude: place_data[:longitude],
            address: place_data[:address],
            place_type: place_data[:type],
            context: place_data[:context],
            position: index
          )
        end
      end
    end

    if @map.save
      redirect_to @map
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete a map and all associated places
  def destroy
    @map.destroy
    redirect_to maps_url, notice: "Map was successfully deleted."
  end

  # Duplicate a map with all its places
  def duplicate
    @original_map = Map.find(params[:id])

    # Check authorization
    unless @original_map.creator == current_user
      redirect_to maps_path, alert: "You are not authorized to duplicate this map."
      return
    end

    # Check if user can create more maps
    unless current_user.can_create_map?
      redirect_to maps_path, alert: "You've reached your map limit. Upgrade to create more maps."
      return
    end

    # Create a duplicate
    @new_map = @original_map.dup
    @new_map.title = "#{@original_map.title} (Copy)"
    @new_map.creator = current_user
    @new_map.places_count = 0  # Reset the counter cache before saving

    if @new_map.save
      # Duplicate all places (counter_cache will auto-increment)
      @original_map.places.each do |place|
        @new_map.places.create(
          name: place.name,
          latitude: place.latitude,
          longitude: place.longitude,
          address: place.address,
          place_type: place.place_type,
          context: place.context,
          position: place.position
        )
      end

      redirect_to @new_map, notice: "Map was successfully duplicated."
    else
      redirect_to @original_map, alert: "Failed to duplicate map."
    end
  end

  private

  # Load the map from params[:id]
  def set_map
    @map = Map.find(params[:id])
  end

  # Authorize viewing a map based on privacy settings
  #
  # Authorization rules:
  # - Public maps: Anyone can view
  # - Shared with link: Anyone with the link can view
  # - Private maps: Only the owner (when signed in) can view
  def authorize_map_view
    # Allow access if map is publicly visible
    return if @map.privacy_publicly_visible?

    # Allow access if map is shared_with_link (anyone with the link can view)
    return if @map.privacy_shared_with_link?

    # Allow access if user is signed in and is the owner
    return if user_signed_in? && @map.creator == current_user

    # Otherwise, deny access
    redirect_to maps_path, alert: "You are not authorized to view this map."
  end

  # Authorize editing/deleting a map (only owner can modify)
  def authorize_map
    unless @map.creator == current_user
      redirect_to maps_path, alert: "You are not authorized to perform this action."
    end
  end

  # Strong parameters for map creation/update
  def map_params
    params.require(:map).permit(:title, :description, :privacy, :original_text)
  end
end
