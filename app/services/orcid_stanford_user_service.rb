# frozen_string_literal: true

# Finds contributors that have an orcid id and a Stanford affiliation, but do not have an orcid in MAIS.
class OrcidStanfordUserService
  def self.execute
    new.execute
  end

  def execute
    orcid_ids = Affiliation.where('label ILIKE ?',
                                  '%Stanford University%')
                           .joins(:abstract_contributor)
                           .where.not(abstract_contributor: { orcid: nil })
                           .pluck(:orcid).uniq
    contributors = orcid_ids.map { |orcid_id| AbstractContributor.find_by(orcid: orcid_id) }
    contributors.select do |contributor|
      mais_orcid_client.fetch_orcid_user(orcidid: contributor.orcid).nil?
    end
  end

  private

  def mais_orcid_client
    @mais_orcid_client ||= MaisOrcidClient.configure(
      client_id: Settings.mais_orcid.client_id,
      client_secret: Settings.mais_orcid.client_secret,
      base_url: Settings.mais_orcid.base_url
    )
  end
end
