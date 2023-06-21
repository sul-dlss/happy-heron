# frozen_string_literal: true

# Utility functions for DOIs
class Doi
  def self.for(druid)
    "#{Settings.datacite.prefix}/#{druid.delete_prefix("druid:")}"
  end
end
