# frozen_string_literal: true

# Downloads files from preservation
class PreservationController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  # rubocop:disable Metrics/AbcSize
  def show
    attached_file = AttachedFile.find(params[:id])
    authorize! attached_file

    attached_file.transform_blob_to_preservation

    # Set headers on the response before writing to the response stream
    send_file_headers!(
      type: "application/octet-stream",
      disposition: "attachment",
      filename: CGI.escape(attached_file.filename.to_s)
    )

    attached_file.file.download do |chunk|
      response.stream.write chunk
    end
  ensure
    response.stream.close
  end
  # rubocop:enable Metrics/AbcSize
end
