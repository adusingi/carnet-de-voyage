class PlaceGeocoder
  EARTH_RADIUS_KM = 6371
  MAX_DISTANCE_KM = 100

  def initialize(places, destination = nil)
    @places = places
    @destination = destination
    @google_api_key = ENV['GOOGLE_MAPS_API_KEY']
  end

  def geocode
    return [] if @places.blank?

    Rails.logger.info "=== GEOCODING STARTED ==="
    Rails.logger.info "Google API Key present: #{@google_api_key.present?}"
    Rails.logger.info "Places to geocode: #{@places.count}"
    Rails.logger.info "Destination: #{@destination}"

    # Get destination coordinates for proximity bias
    proximity_coords = @destination.present? ? get_destination_coords(@destination) : nil

    Rails.logger.info "Proximity coords: #{proximity_coords}" if proximity_coords

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

  def geocode_with_google(place_name, proximity_coords = nil)
    Rails.logger.info "Geocoding place: #{place_name}"

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

    Rails.logger.info "Google Geocoding URL: #{url.gsub(@google_api_key, 'HIDDEN')}"

    response = HTTParty.get(url)
    data = JSON.parse(response.body, symbolize_names: true)

    Rails.logger.info "Google API Response Status: #{data[:status]}"

    if data[:status] == 'OK' && data[:results]&.any?
      result = data[:results].first
      location = result[:geometry][:location]

      Rails.logger.info "✓ Successfully geocoded #{place_name}: #{location[:lat]}, #{location[:lng]}"

      {
        latitude: location[:lat],
        longitude: location[:lng],
        address: result[:formatted_address]
      }
    else
      Rails.logger.warn "Google geocoding returned status: #{data[:status]} for '#{place_name}'"
      Rails.logger.warn "Full response: #{data.inspect}"
      nil
    end
  rescue => e
    Rails.logger.error "Google geocoding error for '#{place_name}': #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

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

  def filter_by_distance(places, proximity_coords)
    places.select do |place|
      distance = calculate_distance(
        proximity_coords[:latitude],
        proximity_coords[:longitude],
        place[:latitude],
        place[:longitude]
      )

      Rails.logger.info "#{place[:name]}: #{distance.round(2)}km from destination"
      distance <= MAX_DISTANCE_KM
    end
  end

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
