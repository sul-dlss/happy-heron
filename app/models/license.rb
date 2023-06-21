# frozen_string_literal: true

# Class contains our valid license identifiers from https://spdx.org/licenses/
#  and other structures used in the work form, model and its validation
class License
  # used for validation in work model

  def self.license_list(include_displayable: false)
    return all.filter_map { |key, license| key if license.selectable } unless include_displayable

    all.keys
  end

  # list for the work form pulldown

  def self.grouped_options(license = nil)
    options = GROUPINGS.map do |group|
      [group.fetch(:label), group.fetch(:options).map { |license_id| [label_for(license_id), license_id] }]
    end
    return options if !license || find(license).selectable

    # If the current license is merely displayable, add the displayable licenses to the dropdown as disabled options
    options.append(
      [
        "Creative Commons 3.0 (Unsupported)",
        all.filter_map do |key, item|
          next if item.selectable

          [item.label, key, {disabled: true}]
        end
      ]
    )
  end

  def self.label_for(license_id)
    find(license_id).label
  end

  def self.find(license_id)
    all.fetch(license_id)
  end

  def self.all
    @all ||= begin
      yaml = YAML.load_file("config/licenses.yml")
      yaml.transform_values do |value|
        Instance.new(value.symbolize_keys)
      end
    end
  end

  Instance = Struct.new(:label, :uri, :selectable, keyword_init: true)

  GROUPINGS = [
    {
      label: "Creative Commons",
      options: [
        "CC0-1.0",
        "CC-BY-4.0",
        "CC-BY-SA-4.0",
        "CC-BY-ND-4.0",
        "CC-BY-NC-4.0",
        "CC-BY-NC-SA-4.0",
        "CC-BY-NC-ND-4.0"
      ]
    },
    {
      label: "Open Data Commons (ODC) licenses",
      options: [
        "PDDL-1.0",
        "ODC-By-1.0",
        "ODbL-1.0"
      ]
    },
    {
      label: "Software Licenses",
      options: [
        "AGPL-3.0-only",
        "Apache-2.0",
        "BSD-2-Clause",
        "BSD-3-Clause",
        "CDDL-1.1",
        "EPL-2.0",
        "GPL-3.0-only",
        "ISC",
        "LGPL-3.0-only",
        "MIT",
        "MPL-2.0"
      ]
    },
    {
      label: "Other",
      options: [
        "none",
        "PDM-1.0"
      ]
    }
  ].freeze
end
