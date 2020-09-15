class DepositProgressComponent < ViewComponent::Base
  def initialize(work:)
    @work = work
  end

  attr_reader :work

  def title?
    work.title.present?
  end
end
