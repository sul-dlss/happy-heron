# typed: true
# frozen_string_literal: true

# Class contains our valid license identifiers from https://spdx.org/licenses/
#  and other structures used in the work form, model and its validation
class License
  extend T::Sig

  # valid, selectable licenses
  SELECTABLE_LICENSES = {
    'CC0-1.0' => 'CC0-1.0',
    'CC-BY-4.0' => 'CC-BY-4.0 Attribution International',
    'CC-BY-SA-4.0' => 'CC-BY-SA-4.0 Attribution-Share Alike International',
    'CC-BY-ND-4.0' => 'CC-BY-ND-4.0 Attribution-No Derivatives International',
    'CC-BY-NC-4.0' => 'CC-BY-NC-4.0 Attribution-NonCommercial International',
    'CC-BY-NC-SA-4.0' => 'CC-BY-NC-SA-4.0 Attribution-NonCommercial-Share Alike International',
    'CC-BY-NC-ND-4.0' => 'CC-BY-NC-ND-4.0 Attribution-NonCommercial-No Derivatives',
    'PDDL-1.0' => 'PDDL-1.0 Public Domain Dedication and License',
    'ODC-By-1.0' => 'ODC-By-1.0 Attribution License',
    'ODbL-1.0' => 'ODbL-1.0 Open Database License',
    'AGPL-3.0-only' => 'AGPL-3.0-only GNU Affero General Public License',
    'Apache-2.0' => 'Apache-2.0',
    'BSD-2-Clause' => 'BSD-2-Clause "Simplified" License',
    'BSD-3-Clause' => 'BSD-3-Clause "New" or "Revised" License',
    'CDDL-1.1' => 'CDDL-1.1 Common Development and Distribution License',
    'EPL-2.0' => 'EPL-2.0 Eclipse Public License',
    'GPL-3.0-only' => 'GPL-3.0-only GNU General Public License',
    'ISC' => 'ISC License',
    'LGPL-3.0-only' => 'LGPL-3.0-only Lesser GNU Public License',
    'MIT' => 'MIT License',
    'MPL-2.0' => 'MPL-2.0 Mozilla Public License',
    'none' => 'No License'
  }.freeze

  # valid, displayable (not selectable) licenses --- used to allow migration of legacy system data
  DISPLAYABLE_LICENSES = {
    'CC-BY-3.0' => 'CC Attribution 3.0 (Unsupported)',
    'CC-BY-SA-3.0' => 'CC Attribution Share Alike 3.0 (Unsupported)',
    'CC-BY-ND-3.0' => 'CC Attribution No Derivatives 3.0 (Unsupported)',
    'CC-BY-NC-3.0' => 'CC Attribution Non Commercial 3.0 (Unsupported)',
    'CC-BY-NC-SA-3.0' => 'CC Attribution Non Commercial Share Alike 3.0 (Unsupported)',
    'CC-BY-NC-ND-3.0' => 'CC Attribution Non Commercial No Derivatives 3.0 (Unsupported)'
  }.freeze

  # used for validation in work model
  sig { params(include_displayable: T::Boolean).returns(T::Array[String]) }
  def self.license_list(include_displayable: false)
    return SELECTABLE_LICENSES.keys unless include_displayable

    SELECTABLE_LICENSES.keys + DISPLAYABLE_LICENSES.keys
  end

  # list for the work form pulldown
  sig { params(license: T.nilable(String)).returns(T::Array[T::Array[T.any(String, T::Array[String])]]) }
  def self.grouped_options(license = nil)
    options = GROUPINGS.map do |group|
      [group.fetch(:label), group.fetch(:options).map { |license_id| [label_for(license_id), license_id] }]
    end
    return options unless license.in?(DISPLAYABLE_LICENSES)

    # If the current license is merely displayable, add the displayable licenses to the dropdown as disabled options
    options.append(
      [
        'Creative Commons 3.0 (Unsupported)',
        DISPLAYABLE_LICENSES.map do |license_id, license_label|
          [license_label, license_id, { disabled: true }]
        end
      ]
    )
  end

  sig { params(license_id: String).returns(String) }
  def self.label_for(license_id)
    SELECTABLE_LICENSES.merge(DISPLAYABLE_LICENSES).fetch(license_id)
  end

  GROUPINGS = [
    {
      label: 'Creative Commons',
      options: [
        'CC0-1.0',
        'CC-BY-4.0',
        'CC-BY-SA-4.0',
        'CC-BY-ND-4.0',
        'CC-BY-NC-4.0',
        'CC-BY-NC-SA-4.0',
        'CC-BY-NC-ND-4.0'
      ]
    },
    {
      label: 'Open Data Commons (ODC) licenses',
      options: [
        'PDDL-1.0',
        'ODC-By-1.0',
        'ODbL-1.0'
      ]
    },
    {
      label: 'Software Licenses',
      options: [
        'AGPL-3.0-only',
        'Apache-2.0',
        'BSD-2-Clause',
        'BSD-3-Clause',
        'CDDL-1.1',
        'EPL-2.0',
        'GPL-3.0-only',
        'ISC',
        'LGPL-3.0-only',
        'MIT',
        'MPL-2.0'
      ]
    },
    {
      label: 'No License',
      options: ['none']
    }
  ].freeze
end
