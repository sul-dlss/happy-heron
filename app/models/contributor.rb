class Contributor < ApplicationRecord
  belongs_to :work
  belongs_to :role_term
end
