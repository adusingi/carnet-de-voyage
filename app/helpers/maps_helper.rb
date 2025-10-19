module MapsHelper
  # Highlight place names in the trip notes with clickable links
  # Combines Noteplan's simple approach with multilingual support
  def highlight_place_names(text, places)
    return text if text.blank? || places.empty?

    highlighted_text = text.dup

    # Sort places by name length (longest first) to avoid partial replacements
    # e.g., replace "The Raines Law Room at The William" before "The William"
    sorted_places = places.sort_by { |p| -p.name.to_s.length }

    sorted_places.each do |place|
      place_name = place.name.to_s.strip
      next if place_name.blank?

      # Find the actual index in the original places array
      actual_index = places.index(place)

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
