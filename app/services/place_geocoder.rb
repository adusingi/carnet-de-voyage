# Service for converting place names to geographic coordinates using Google Maps Geocoding API.
#
# This service takes an array of place names and returns their latitude/longitude coordinates,
# with optional filtering by distance from a central destination.
#
# @example
#   places = [{ name: "Eiffel Tower" }, { name: "Louvre Museum" }]
#   geocoder = PlaceGeocoder.new(places, "Paris, France")
#   result = geocoder.geocode
#   # => [{ name: "Eiffel Tower", latitude: 48.858, longitude: 2.294, ... }, ...]
class PlaceGeocoder
  # Earth's radius in kilometers for distance calculations
  EARTH_RADIUS_KM = 6371

  # Maximum distance in km from destination to include a place (filters out incorrect matches)
  MAX_DISTANCE_KM = 100

  # Initialize the geocoder with places to convert to coordinates
  #
  # @param places [Array<Hash>] Array of place hashes with :name key
  # @param destination [String, nil] Optional destination name for proximity bias and filtering
  def initialize(places, destination = nil)
    @places = places
    @destination = destination
    @google_api_key = ENV['GOOGLE_MAPS_API_KEY']
  end

  # Geocode all places to latitude/longitude coordinates
  #
  # @return [Array<Hash>] Array of geocoded place hashes with keys:
  #   - name [String] Place name
  #   - latitude [Float] Latitude coordinate
  #   - longitude [Float] Longitude coordinate
  #   - address [String] Formatted address from Google
  #   - type [String] Place type (restaurant, landmark, etc.)
  #   - context [String] Additional context about the place
  def geocode
    return [] if @places.blank?

    Rails.logger.info "=== GEOCODING STARTED ==="
    Rails.logger.debug "Google API Key present: #{@google_api_key.present?}"
    Rails.logger.info "Places to geocode: #{@places.count}"
    Rails.logger.debug "Destination: #{@destination}"

    # Get destination coordinates for proximity bias
    proximity_coords = @destination.present? ? get_destination_coords(@destination) : nil

    Rails.logger.debug "Proximity coords: #{proximity_coords}" if proximity_coords

    # Geocode all places in parallel
    geocoded = @places.map do |place|
      geocode_place(place, proximity_coords)
    end.compact

    # Filter places by distance if we have proximity coords
    if proximity_coords && geocoded.any?
      geocoded = filter_by_distance(geocoded, proximity_coords)
    end

    geocoded
  end

  private

  # Geocode a single place to coordinates
  #
  # @param place [Hash] Place hash with :name key
  # @param proximity_coords [Hash, nil] Optional coordinates for proximity bias
  # @return [Hash, nil] Geocoded place hash or nil if geocoding failed
  def geocode_place(place, proximity_coords = nil)
    place_name = place[:name] || place['name']
    return nil if place_name.blank?

    result = geocode_with_google(place_name, proximity_coords)
    return nil unless result

    {
      name: place_name,
      latitude: result[:latitude],
      longitude: result[:longitude],
      address: result[:address],
      type: place[:type] || place['type'],
      context: place[:context] || place['context']
    }
  end

  # Call Google Maps Geocoding API to convert place name to coordinates
  #
  # @param place_name [String] Name of the place to geocode
  # @param proximity_coords [Hash, nil] Optional coordinates for location bias
  # @return [Hash, nil] Hash with :latitude, :longitude, :address keys or nil
  def geocode_with_google(place_name, proximity_coords = nil)
    Rails.logger.debug "Geocoding place: #{place_name}"

    unless @google_api_key.present?
      Rails.logger.error "Google API key is missing!"
      return nil
    end

    search_query = @destination ? "#{place_name}, #{@destination}" : place_name
    encoded_place = ERB::Util.url_encode(search_query)

    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{encoded_place}&key=#{@google_api_key}"

    # Add location bias if we have proximity coordinates
    if proximity_coords
      url += "&location=#{proximity_coords[:latitude]},#{proximity_coords[:longitude]}&radius=50000"
    end

    Rails.logger.debug "Google Geocoding URL: #{url.gsub(@google_api_key, 'HIDDEN')}"

    response = HTTParty.get(url)
    data = JSON.parse(response.body, symbolize_names: true)

    Rails.logger.debug "Google API Response Status: #{data[:status]}"

    # Handle different Google Geocoding API status codes explicitly
    case data[:status]
    when 'OK'
      if data[:results]&.any?
        result = data[:results].first
        location = result[:geometry][:location]

        Rails.logger.debug "✓ Successfully geocoded #{place_name}: #{location[:lat]}, #{location[:lng]}"

        {
          latitude: location[:lat],
          longitude: location[:lng],
          address: result[:formatted_address]
        }
      else
        Rails.logger.warn "No results found for '#{place_name}'"
        nil
      end
    when 'ZERO_RESULTS'
      Rails.logger.debug "No location found for '#{place_name}'"
      nil
    when 'OVER_QUERY_LIMIT'
      Rails.logger.error "Google Geocoding API quota exceeded for '#{place_name}'"
      nil
    when 'REQUEST_DENIED'
      Rails.logger.error "Google Geocoding API request denied (check API key) for '#{place_name}'"
      nil
    when 'INVALID_REQUEST'
      Rails.logger.error "Invalid geocoding request for '#{place_name}'"
      nil
    when 'UNKNOWN_ERROR'
      Rails.logger.error "Google Geocoding API server error for '#{place_name}' - retrying may succeed"
      nil
    else
      Rails.logger.warn "Unexpected Google geocoding status: #{data[:status]} for '#{place_name}'"
      nil
    end
  rescue => e
    Rails.logger.error "Google geocoding error for '#{place_name}': #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  # Get coordinates for a destination city/region
  #
  # @param destination [String] Destination name
  # @return [Hash, nil] Hash with :latitude and :longitude keys or nil
  def get_destination_coords(destination)
    result = geocode_with_google(destination)
    return nil unless result

    {
      latitude: result[:latitude],
      longitude: result[:longitude]
    }
  rescue => e
    Rails.logger.error "Error getting destination coords: #{e.message}"
    nil
  end

  # Filter places by maximum distance from destination
  #
  # @param places [Array<Hash>] Places with :latitude and :longitude
  # @param proximity_coords [Hash] Destination coordinates with :latitude and :longitude
  # @return [Array<Hash>] Filtered places within MAX_DISTANCE_KM
  def filter_by_distance(places, proximity_coords)
    places.select do |place|
      distance = calculate_distance(
        proximity_coords[:latitude],
        proximity_coords[:longitude],
        place[:latitude],
        place[:longitude]
      )

      Rails.logger.debug "#{place[:name]}: #{distance.round(2)}km from destination"
      distance <= MAX_DISTANCE_KM
    end
  end

  # Calculate distance between two coordinates using Haversine formula
  #
  # @param lat1 [Float] Latitude of first point
  # @param lon1 [Float] Longitude of first point
  # @param lat2 [Float] Latitude of second point
  # @param lon2 [Float] Longitude of second point
  # @return [Float] Distance in kilometers
  def calculate_distance(lat1, lon1, lat2, lon2)
    d_lat = (lat2 - lat1) * Math::PI / 180
    d_lon = (lon2 - lon1) * Math::PI / 180

    a = Math.sin(d_lat / 2) * Math.sin(d_lat / 2) +
        Math.cos(lat1 * Math::PI / 180) * Math.cos(lat2 * Math::PI / 180) *
        Math.sin(d_lon / 2) * Math.sin(d_lon / 2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    EARTH_RADIUS_KM * c
  end
end
