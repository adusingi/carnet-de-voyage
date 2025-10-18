require 'prawn'

class MapPdfGenerator
  def initialize(map)
    @map = map
    @places = map.places.ordered
  end

  def generate
    Prawn::Document.new do |pdf|
      # Helper method to sanitize text for PDF
      def sanitize_for_pdf(text)
        return "" if text.blank?
        # Convert to ASCII-compatible encoding, replacing problematic characters
        text.encode('ISO-8859-1', invalid: :replace, undef: :replace, replace: '?')
      rescue
        text.to_s
      end

      # Title
      pdf.font "Helvetica", style: :bold, size: 24
      pdf.text sanitize_for_pdf(@map.title), align: :center
      pdf.move_down 10

      # Destination
      if @map.destination.present?
        pdf.font "Helvetica", size: 12
        pdf.text "Destination: #{sanitize_for_pdf(@map.destination)}", align: :center
        pdf.move_down 5
      end

      # Creator and date
      pdf.font "Helvetica", size: 10
      pdf.text "Created by #{sanitize_for_pdf(@map.creator.username)} - #{@map.created_at.strftime('%B %d, %Y')}",
               align: :center, color: "666666"
      pdf.move_down 20

      # Description
      if @map.description.present?
        pdf.font "Helvetica", size: 11
        pdf.text sanitize_for_pdf(@map.description)
        pdf.move_down 15
      end

      # Google Maps Link
      if @map.google_maps_url.present?
        pdf.font "Helvetica", style: :bold, size: 12
        pdf.text "Open in Google Maps:", color: "0000FF"
        pdf.font "Helvetica", size: 10
        pdf.text @map.google_maps_url, color: "0000EE"
        pdf.move_down 20
      end

      # Places section
      pdf.font "Helvetica", style: :bold, size: 14
      pdf.text "Places (#{@places.count})"
      pdf.move_down 10

      @places.each_with_index do |place, index|
        # Place number and name
        pdf.font "Helvetica", style: :bold, size: 12
        pdf.text "#{index + 1}. #{sanitize_for_pdf(place.name)}"

        # Type badge
        if place.place_type.present?
          pdf.font "Helvetica", size: 9
          pdf.text "  [#{sanitize_for_pdf(place.place_type).upcase}]", color: "0066CC"
        end

        # Context
        if place.context.present?
          pdf.font "Helvetica", size: 10
          pdf.text "  #{sanitize_for_pdf(place.context)}", color: "333333"
        end

        # Address
        if place.address.present?
          pdf.font "Helvetica", size: 9
          pdf.text "  Location: #{sanitize_for_pdf(place.address)}", color: "666666"
        end

        # Coordinates
        if place.latitude.present? && place.longitude.present?
          pdf.font "Helvetica", size: 8
          pdf.text "  Coordinates: #{place.latitude}, #{place.longitude}", color: "999999"
        end

        pdf.move_down 12
      end

      # Original notes
      if @map.original_text.present?
        pdf.start_new_page
        pdf.font "Helvetica", style: :bold, size: 14
        pdf.text "Original Trip Notes"
        pdf.move_down 10
        pdf.font "Helvetica", size: 10
        pdf.text sanitize_for_pdf(@map.original_text)
      end

      # Footer
      pdf.number_pages "Page <page> of <total>",
                       at: [pdf.bounds.right - 150, 0],
                       width: 150,
                       align: :right,
                       size: 9
    end
  end
end
