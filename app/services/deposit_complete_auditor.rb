# Looks for WorkVersion that are still in the depositing state, but accessioning is complete.
# This happens when notification of the DepositCompleteJob fails.
class DepositCompleteAuditor
  def self.execute
    new.execute
  end

  def execute
    depositing_objects.each do |object|
      next if accessioning?(object)

      Honeybadger.notify("Object is still in depositing state, but accessioning is complete", context: {druid: object.druid, version: object.head.version})
      Rails.logger.info("Object is still in depositing state, but accessioning is complete: #{object.druid}")
      DepositCompleter.complete(object_version: object.head)
    end
  end

  private

  def depositing_objects
    Work.all.joins(:head).where(head: {state: "depositing"}).to_a + \
      Collection.all.joins(:head).where(head: {state: "depositing"}).to_a
  end

  def workflow_client
    @workflow_client ||= Dor::Workflow::Client.new(url: Settings.workflow_url)
  end

  def accessioning?(object)
    workflow_client.active_lifecycle(druid: object.druid, milestone_name: "submitted", version: object.head.version.to_s).present?
  end
end
