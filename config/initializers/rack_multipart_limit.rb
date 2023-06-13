# frozen_string_literal: true

# Allow uploading many files at a time: https://github.com/sul-dlss/happy-heron/issues/3051
Rack::Utils.multipart_total_part_limit = 0
