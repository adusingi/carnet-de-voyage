# Helper methods for displaying and interacting with travel maps
module MapsHelper
  # Highlight place names in travel notes with clickable links
  #
  # Converts plain text place names into interactive links that can trigger
  # map interactions. Supports multilingual place names including French accents.
  # Uses multiple matching strategies to handle variations in place names.
  #
  # @param text [String] The original travel notes text
  # @param places [Array<Place>] Array of Place objects to highlight
  # @return [ActiveSupport::SafeBuffer] HTML-safe string with highlighted places
  #
  # @example
  #   text = "Visit the Eiffel Tower and eat at Le Jules Verne"
  #   places = [Place.new(name: "Eiffel Tower"), Place.new(name: "Le Jules Verne")]
  #   highlight_place_names(text, places)
  #   # => "Visit the <a href='#' class='place-link' ...>Eiffel Tower</a>..."
  def highlight_place_names(text, places)
    return text if text.blank? || places.empty?

    highlighted_text = text.dup

    # Precompute index map for O(1) lookup instead of O(n) - prevents O(n²) complexity
    place_index_map = {}
    places.each_with_index { |place, idx| place_index_map[place.object_id] = idx }

    # Sort places by name length (longest first) to avoid partial replacements
    # e.g., replace "The Raines Law Room at The William" before "The William"
    sorted_places = places.sort_by { |p| -p.name.to_s.length }

    sorted_places.each do |place|
      place_name = place.name.to_s.strip
      next if place_name.blank?

      # Find the actual index in the original places array using precomputed map
      actual_index = place_index_map[place.object_id]

      # Decode HTML entities (e.g., "&amp;" -> "&", "&#39;" -> "'")
      decoded_name = CGI.unescapeHTML(place_name)

      # Strategy 1: Try exact match first (like Noteplan)
      # This handles "The Up & Up", "Mother's Ruin", etc.
      escaped = Regexp.escape(decoded_name)
      regex = /(#{escaped})/i

      match_found = false
      highlighted_text.gsub!(regex) do |match|
        # Check if we're already inside a link tag
        if $` =~ /<a[^>]*class='place-link'[^>]*>[^<]*\z/
          match
        else
          match_found = true
          "<a href='#' class='place-link' data-place-index='#{actual_index}' style='color: #0ea5e9; font-weight: 600; text-decoration: none; cursor: pointer;'>#{match}</a>"
        end
      end

      # Strategy 2: If no exact match, try core name extraction for multilingual support
      # This handles "Hamarikyu Garden" (English) matching "jardin Hamarikyu" (French)
      unless match_found
        core_names = extract_core_names(decoded_name)
        core_names.sort_by! { |n| -n.length }

        core_names.each do |core_name|
          next if core_name.length < 4
          next if core_name.downcase == decoded_name.downcase  # Already tried

          escaped_core = Regexp.escape(core_name)
          regex_core = /(#{escaped_core})/i

          highlighted_text.gsub!(regex_core) do |match|
            # Check if already inside a link
            if $` =~ /<a[^>]*class='place-link'[^>]*>[^<]*\z/
              match
            else
              "<a href='#' class='place-link' data-place-index='#{actual_index}' style='color: #0ea5e9; font-weight: 600; text-decoration: none; cursor: pointer;'>#{match}</a>"
            end
          end
        end
      end
    end

    highlighted_text.html_safe
  end

  private

  # Extract core name components from a place name for flexible matching
  #
  # Uses multiple strategies to extract meaningful parts of place names:
  # - Full name, core name (without suffixes like "Garden", "Museum")
  # - Hyphenated compounds (e.g., "Edo-Tokyo")
  # - Capitalized proper nouns
  # - Multi-word combinations
  #
  # @param place_name [String] The full place name
  # @return [Array<String>] Array of name variants to try matching
  #
  # @example
  #   extract_core_names("Hamarikyu Garden")
  #   # => ["Hamarikyu Garden", "Hamarikyu", ...]
  def extract_core_names(place_name)
    # Decode HTML entities
    decoded = CGI.unescapeHTML(place_name)

    # Common generic words to exclude when standalone
    generic_words = %w[Garden Museum Temple Market Street Shrine Park Castle Palace Tower Station Hotel Restaurant Bar Cafe Scramble]

    # Try multiple strategies to extract meaningful parts
    names = []

    # Strategy 1: Full name
    names << decoded

    # Strategy 2: Remove common English suffixes (Garden, Museum, Temple, etc.)
    core = decoded.gsub(/\s+(Garden|Museum|Temple|Market|Street|Shrine|Park|Castle|Palace|Tower|Station|Hotel|Restaurant|Bar|Cafe|Scramble)$/i, '')
    names << core if core != decoded

    # Strategy 3: Get hyphenated compounds (like "Edo-Tokyo", "Senso-ji", "Café-Restaurant")
    # Use Unicode character classes to support accented characters (É, è, ô, etc.)
    decoded.scan(/([[:upper:]][[:lower:]]+-[[:upper:]][[:lower:]]+)/i).flatten.each { |compound| names << compound }

    # Strategy 4: Extract all capitalized words (proper nouns)
    # This will get "Hamarikyu", "Tsukiji", "Edo", "Tokyo", "Senso", "Nakamise", "Shibuya", "Étoile", "Château"
    # But exclude generic words
    # Unicode support: [[:upper:]] matches É, Ç, Ł, etc.; [[:lower:]] matches é, è, ô, etc.
    decoded.scan(/\b([[:upper:]][[:lower:]]{2,})\b/).flatten.each do |word|
      names << word unless generic_words.include?(word)
    end

    # Strategy 5: Get combinations of consecutive capitalized words
    # This handles "Shibuya Scramble" -> "Shibuya Scramble", "Arc de Triomphe" -> "Arc"
    words = decoded.split(/\s+/)
    words.each_with_index do |word, i|
      if word =~ /^[[:upper:]][[:lower:]]{2,}$/
        # Also try combining with next word if it's also capitalized
        if i + 1 < words.length && words[i + 1] =~ /^[[:upper:]]/
          names << "#{word} #{words[i + 1]}"
        end
      end
    end

    # Remove duplicates, nils, and very short names
    # Also filter out standalone generic words
    names.uniq.compact
         .reject { |n| n.length < 3 }
         .reject { |n| generic_words.map(&:downcase).include?(n.downcase) && !n.include?(' ') && !n.include?('-') }
  end
end
