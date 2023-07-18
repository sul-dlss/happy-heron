# Finds orcid ids for Stanford users that have only granted read permissions.
class OrcidReadLimitedUserService
  def self.execute
    new.execute
  end

  # @return [Array<MaisOrcidClient::OrcidUser>] orcid users that have only granted read permissions
  def execute
    orcid_ids.map do |orcid|
      next unless orcid
      orcid_user = mais_orcid_client.fetch_orcid_user(orcidid: orcid)
      next unless orcid_user

      orcid_user unless orcid_user.update?
    end.compact
  end

  private

  def orcid_ids
    AbstractContributor.select(:orcid).distinct.pluck(:orcid)
  end

  def mais_orcid_client
    @mais_orcid_client ||= MaisOrcidClient.configure(
      client_id: Settings.mais_orcid.client_id,
      client_secret: Settings.mais_orcid.client_secret,
      base_url: Settings.mais_orcid.base_url
    )
  end
end
