# typed: true
# frozen_string_literal: true

# Actions that happen when something happens to a collection
class CollectionObserver
  def self.collection_activity(work, _transition)
    work.collection.managers.reject { |manager| manager == work.depositor }.each do |user|
      mailer = CollectionsMailer.with(user: user, collection: work.collection, depositor: work.depositor)
      mailer.collection_activity.deliver_later
    end
  end
end
