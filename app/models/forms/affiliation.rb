module Forms
  class Affiliation < Base
    # Indicates that this is a deposit, and therefore should be fully validated.
    attr_accessor :_deposit
    attr_accessor :id
    attr_accessor :label
    attr_accessor :uri
    attr_accessor :department
    attr_accessor :abstract_contributor
    attr_accessor :_destroy

    validates :label, presence: true, if: :_deposit

    def main_model
      affiliation
    end

    def affiliation
      @affiliation ||= begin
        affiliation = if id.present?
          ::Affiliation.find(id)
        else
          ::Affiliation.new
        end
        affiliation.label = label
        affiliation.uri = uri
        affiliation.department = department
        affiliation.abstract_contributor = abstract_contributor
        affiliation
      end
    end

    def self.new_from_model(affiliation)
      new(id: affiliation.id,
        abstract_contributor: affiliation.abstract_contributor,
        label: affiliation.label,
        uri: affiliation.uri,
        department: affiliation.department)
    end
  end
end
