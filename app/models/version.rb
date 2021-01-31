class Version < ApplicationRecord
  belongs_to :versionable, polymorphic: true
end
