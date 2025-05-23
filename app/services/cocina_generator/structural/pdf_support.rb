# frozen_string_literal: true

module CocinaGenerator
  module Structural
    # Support for PDF files
    class PdfSupport
      def self.pdf?(cocina_file:)
        # For some files the mime type is not yet set so guess based on the filename.
        if cocina_file.hasMimeType.present?
          cocina_file.hasMimeType == 'application/pdf'
        else
          cocina_file.filename.ends_with?('.pdf')
        end
      end
    end
  end
end
