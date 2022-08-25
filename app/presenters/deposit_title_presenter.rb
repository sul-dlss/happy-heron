# frozen_string_literal: true

# A helper for displaying a title for a Work or Collection
class DepositTitlePresenter
  def self.show(deposit)
    if deposit.instance_of?(WorkVersion)
      deposit&.title.presence || Settings.h2.no_title
    elsif deposit.instance_of?(CollectionVersion)
      deposit&.name.presence || Settings.h2.no_title
    end
  end
end
