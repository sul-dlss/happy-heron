# typed: false
# frozen_string_literal: true

class CollectionForm < Reform::Form
  property :name
  property :description
  property :contact_email
  property :managers, prepopulator: lambda { |_options|
    self.managers = model.creator.email.delete_suffix('@stanford.edu')
  }
  property :access, default: 'world'
  property :creator, writable: false
  property :depositor_sunets, virtual: true, prepopulator: lambda { |_options|
    self.depositor_sunets = model.depositors.map { |user| user.email.delete_suffix('@stanford.edu') }
  }

  def sync(*)
    sunetids = depositor_sunets.split(/\s*,\s*/)
    emails = sunetids.map { |sunet| "#{sunet}@stanford.edu" }
    model.depositors = emails.map { |email| User.create_or_find_by(email: email) }
    super
  end

  validates :name, :description, :contact_email, :managers, :access, presence: true
end
