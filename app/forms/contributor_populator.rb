# typed: true
# frozen_string_literal: true

# Populates the nested contributor form
class ContributorPopulator < ApplicationPopulator
  # The fragment represents one row of the contributor data from the HTML form
  # find out if incoming Contributor is already added.
  # rubocop:disable Metrics/AbcSize
  def call(form, fragment:, **)
    item = existing_record(form: form, id: fragment['id'])

    if fragment['_destroy'] == '1'
      value(form).delete(item)
      return skip!
    elsif fragment['first_name'].blank? && fragment['full_name'].blank?
      return skip!
    end

    # Clear out names that we don't want to store (e.g. first & last name for an organization)
    # These can get submitted to the server if the user enters a person
    # name and then switches the type/role to an organization name.
    if fragment['role_term'].start_with?('person')
      fragment['full_name'] = nil
    else
      fragment['first_name'] = nil
      fragment['last_name'] = nil
    end
    item || value(form).append(klass.new)
  end
  # rubocop:enable Metrics/AbcSize
end
