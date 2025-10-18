class GoogleMapsUrlGenerator
  def initialize(map)
    @map = map
    @places = map.places.ordered
  end

  # Generate a shareable Google Maps URL with all places
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

  # Generate URL using place names instead of coordinates (more user-friendly)
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

  # Generate a shortened Google Maps link (requires Places API call)
  # This would create links like https://maps.app.goo.gl/xyz123
  # Note: This requires creating a "saved map" via Google Maps API which is more complex
  # For now, we'll use the direct URL approach above
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
