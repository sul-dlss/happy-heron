# frozen_string_literal: true

# A helper for displaying a title for a Collection
class CollectionTitlePresenter
  def self.show(collection_version)
    collection_version.name.presence || I18n.t('deposit.no_title')
  end
end
