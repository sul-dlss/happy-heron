module Forms
  class Contributor < Base
    # Indicates that this is a deposit, and therefore should be fully validated.
    attr_accessor :_deposit
    attr_accessor :id
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :full_name
    attr_accessor :with_orcid # radio button
    attr_accessor :orcid
    attr_accessor :work_version
    attr_accessor :_destroy
    # role term is a composite field. See AbstractContributor
    attr_accessor :role_term
    attr_accessor :weight

    # affiliations_attributes is needed in order to use the
    # fields_for helper with a collection
    attr_accessor :affiliations_attributes

    with_options if: -> { _deposit && role_term&.start_with?("person") } do
      validates :first_name, presence: true
      validates :last_name, presence: true
    end

    with_options if: -> { _deposit && !role_term&.start_with?("person") } do
      validates :full_name, presence: true
    end

    # Override to use a different ActiveRecord model, e.g., Author
    def clazz
      ::Contributor
    end

    def main_model
      contributor
    end

    def associated_forms
      affiliations
    end

    def contributor
      @contributor ||= begin
        contributor = if id.present?
          clazz.find(id)
        else
          clazz.new
        end
        contributor.first_name = first_name
        contributor.last_name = last_name
        contributor.work_version = work_version
        contributor.role_term = role_term if role_term.present?
        contributor.full_name = full_name
        contributor.orcid = with_orcid? ? orcid : nil
        contributor.weight = weight
        contributor
      end
    end

    def with_orcid?
      with_orcid == "true"
    end

    def affiliations
      @affiliations ||= if affiliations_attributes.present?
        affiliations_attributes.filter_map do |_, affiliation_params|
          Forms::Affiliation.new(affiliation_params.merge(abstract_contributor: contributor, _deposit: _deposit)) unless Forms::Affiliation.reject_all_blank?(affiliation_params)
        end
      elsif contributor.affiliations.present?
        contributor.affiliations.map do |affiliation|
          Forms::Affiliation.new_from_model(affiliation)
        end
      else
        []
      end
    end

    def affiliations_forms
      affiliations.present? ? affiliations : [Forms::Affiliation.new]
    end

    def self.new_from_model(contributor)
      new(id: contributor.id,
        first_name: contributor.first_name,
        last_name: contributor.last_name,
        work_version: contributor.work_version,
        role_term: contributor.role_term,
        full_name: contributor.full_name,
        orcid: contributor.orcid,
        with_orcid: contributor.orcid.present?,
        weight: contributor.weight)
    end

    def self.reject_all_blank?(params)
      super(params.except("with_orcid", "role_term"))
    end
  end
end
