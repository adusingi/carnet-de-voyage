module MapsHelper
  # Highlight place names in the trip notes with green/teal color
  def highlight_place_names(text, places)
    return text if text.blank? || places.empty?

    # Get all place names
    place_names = places.map(&:name).compact.uniq

    # Sort by length (longest first) to avoid partial replacements
    place_names.sort_by! { |name| -name.length }

    # Replace each place name with highlighted version
    highlighted_text = text.dup
    place_names.each do |name|
      # Use word boundary matching to avoid partial matches
      highlighted_text.gsub!(/\b#{Regexp.escape(name)}\b/i) do |match|
        "<span class='text-teal-600 font-medium'>#{match}</span>"
      end
    end

    highlighted_text.html_safe
  end
end
