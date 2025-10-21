# Service for generating shareable Google Maps URLs from a map's places.
#
# Creates URLs that open Google Maps with the specified places pre-loaded,
# allowing users to view and navigate the trip on Google Maps.
#
# @example
#   generator = GoogleMapsUrlGenerator.new(map)
#   url = generator.generate_url
#   # => "https://www.google.com/maps/search/Eiffel+Tower/Louvre+Museum"
class GoogleMapsUrlGenerator
  # Initialize the URL generator with a map
  #
  # @param map [Map] The map containing places to generate a URL for
  def initialize(map)
    @map = map
    @places = map.places.ordered
  end

  # Generate a shareable Google Maps URL with all places
  #
  # @return [String, nil] Google Maps URL or nil if no places exist
  def generate_url
    return nil if @places.empty?

    if @places.count == 1
      # Single place - use name if available, otherwise coordinates
      place = @places.first
      query = place.name.present? ? ERB::Util.url_encode(place.name) : "#{place.latitude},#{place.longitude}"
      "https://www.google.com/maps/search/?api=1&query=#{query}"
    else
      # Multiple places - use names for search query
      # This shows all places with their names as individual pins
      queries = @places.map { |p|
        p.name.present? ? ERB::Util.url_encode(p.name) : "#{p.latitude},#{p.longitude}"
      }.join('/')

      "https://www.google.com/maps/search/#{queries}"
    end
  end

  # Generate URL using place names with directions between points
  #
  # @return [String, nil] Google Maps directions URL or nil if no places exist
  def generate_url_with_names
    return nil if @places.empty?

    if @places.count == 1
      # Single place
      place = @places.first
      encoded_name = ERB::Util.url_encode(place.name)
      "https://www.google.com/maps/search/?api=1&query=#{encoded_name}"
    else
      # Multiple places using place IDs or names
      # Google Maps supports searching multiple locations
      query = @places.map { |p| ERB::Util.url_encode(p.name) }.join('+to:')
      "https://www.google.com/maps/dir/?api=1&query=#{query}"
    end
  end

  # Generate a shortened Google Maps link (placeholder for future implementation)
  #
  # This would create links like https://maps.app.goo.gl/xyz123
  # Note: This requires creating a "saved map" via Google Maps API which is more complex.
  # For now, we use the direct URL approach above.
  #
  # @return [String, nil] Currently returns same as generate_url
  def generate_short_url
    # This would require:
    # 1. Google Maps Platform API credentials
    # 2. Create a custom map via API
    # 3. Get the short URL from the response
    #
    # For MVP, we'll use the direct URLs above which work perfectly for sharing
    generate_url
  end
end
