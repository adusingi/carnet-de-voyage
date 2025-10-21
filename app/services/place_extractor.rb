# Service for extracting travel places and destinations from natural language text using OpenAI's GPT-4.
#
# This service analyzes travel notes, itineraries, or descriptions to identify:
# - The primary destination (city, region, or country)
# - Specific places mentioned (restaurants, landmarks, hotels, etc.)
# - Place types and contextual descriptions
#
# @example
#   extractor = PlaceExtractor.new("Visit Tokyo Tower and eat at Sukiyabashi Jiro")
#   result = extractor.extract
#   # => { success: true, destination: "Tokyo, Japan", places: [...] }
class PlaceExtractor
  # Initialize the place extractor with text to analyze
  #
  # @param text [String] The travel notes or description to extract places from
  def initialize(text)
    @text = text
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  # Extract destination and places from the provided text using OpenAI API
  #
  # @return [Hash] Result hash with the following structure:
  #   - success [Boolean] Whether extraction was successful
  #   - destination [String] The primary destination (if success: true)
  #   - places [Array<Hash>] Array of place objects with :name, :context, :type (if success: true)
  #   - error [String] Error message (if success: false)
  #
  # @example Successful extraction
  #   extract
  #   # => {
  #   #   success: true,
  #   #   destination: "Paris, France",
  #   #   places: [
  #   #     { name: "Eiffel Tower", context: "iconic landmark", type: "landmark" },
  #   #     { name: "Le Jules Verne", context: "Michelin restaurant", type: "restaurant" }
  #   #   ]
  #   # }
  #
  # @example Failed extraction
  #   extract
  #   # => { success: false, error: "Request timed out. Please try again." }
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
              content: 'You are a travel planning assistant that extracts location information from trip notes. You must respond with valid JSON matching the provided schema.'
            },
            {
              role: 'user',
              content: build_prompt
            }
          ],
          response_format: {
            type: 'json_schema',
            json_schema: {
              name: 'place_extraction',
              strict: true,
              schema: {
                type: 'object',
                properties: {
                  destination: { type: 'string' },
                  places: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        name: { type: 'string' },
                        context: { type: 'string' },
                        type: { type: 'string' }
                      },
                      required: ['name', 'context', 'type'],
                      additionalProperties: false
                    }
                  }
                },
                required: ['destination', 'places'],
                additionalProperties: false
              }
            }
          },
          temperature: 0.2,
          max_tokens: 800  # Limit response size to prevent runaway costs
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
      { success: false, error: 'Failed to parse extracted places. Please try again.' }
    rescue Faraday::TimeoutError => e
      Rails.logger.error "OpenAI API timeout: #{e.message}"
      { success: false, error: 'Request timed out. Please try again.' }
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error "Failed to connect to OpenAI: #{e.message}"
      { success: false, error: 'Could not connect to the AI service. Please check your internet connection.' }
    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API error: #{e.message}"
      if e.message.include?('rate_limit')
        { success: false, error: 'AI service is busy. Please try again in a moment.' }
      elsif e.message.include?('invalid_api_key')
        { success: false, error: 'AI service configuration error. Please contact support.' }
      else
        { success: false, error: 'AI service error. Please try again.' }
      end
    rescue => e
      Rails.logger.error "Unexpected error extracting places: #{e.class} - #{e.message}"
      { success: false, error: 'An unexpected error occurred. Please try again.' }
    end
  end

  private

  # Build the prompt for OpenAI that instructs it how to extract places
  #
  # @return [String] The formatted prompt with instructions and user text
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
