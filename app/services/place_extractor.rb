class PlaceExtractor
  def initialize(text)
    @text = text
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def extract
    return { success: false, error: 'No text provided' } if @text.blank?

    begin
      Rails.logger.info 'Calling OpenAI API for place extraction...'

      response = @client.chat(
        parameters: {
          model: 'gpt-4o-mini',
          messages: [
            {
              role: 'system',
              content: 'You are a travel planning assistant that extracts location information from trip notes. You must respond with valid JSON only.'
            },
            {
              role: 'user',
              content: build_prompt
            }
          ],
          response_format: { type: 'json_object' },
          temperature: 0.2
        }
      )

      Rails.logger.info 'OpenAI response received'

      content = response.dig('choices', 0, 'message', 'content')
      return { success: false, error: 'No response from OpenAI' } unless content

      result = JSON.parse(content, symbolize_names: true)
      destination = result[:destination] || 'Unknown'

      # Handle different response formats
      places = if result.is_a?(Array)
                 result
               else
                 result[:places] || result[:locations] || []
               end

      Rails.logger.info "Detected destination: #{destination}"
      Rails.logger.info "Extracted places: #{places.length}"

      {
        success: true,
        destination: destination,
        places: places
      }
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse OpenAI response: #{e.message}"
      { success: false, error: 'Failed to parse extracted places' }
    rescue => e
      Rails.logger.error "Error extracting places: #{e.message}"
      { success: false, error: e.message }
    end
  end

  private

  def build_prompt
    <<~PROMPT
      Analyze this travel text and extract location information.

      First, identify the PRIMARY DESTINATION (city, region, or country) the user is traveling to or writing about.
      Then, extract ONLY places (landmarks, restaurants, hotels, attractions) that are located IN or NEAR that primary destination.

      Ignore places in other cities or countries unless they are clearly part of the same trip.

      Return JSON in this exact format:
      {
        "destination": "City Name, Country",
        "places": [
          {
            "name": "Place Name",
            "context": "brief description from text",
            "type": "restaurant|bar|cafe|hotel|landmark|museum|park|shopping|nightlife|attraction"
          }
        ]
      }

      Choose the most appropriate type for each place.

      Text:
      #{@text}
    PROMPT
  end
end
