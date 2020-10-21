# typed: strict
# frozen_string_literal: true

# Represents the list of valid work types
class License
  extend T::Sig

  sig { returns(String) }
  attr_reader :id

  sig { returns(String) }
  attr_reader :label

  sig { params(id: String, label: String).void }
  def initialize(id:, label:)
    @id = id
    @label = label
  end

  # id is an identifier from https://spdx.org/licenses/
  sig { returns(T::Array[License]) }
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.all
    [
      new(id: 'CC-PDDC', label: 'Public domain mark'),
      new(id: 'CC0-1.0', label: 'CC0 1.0'),
      new(id: 'CC-BY-4.0', label: 'CC BY 4.0'),
      new(id: 'CC-BY-SA-4.0', label: 'CC BY-SA 4.0'),
      new(id: 'CC-BY-ND-4.0', label: 'CC BY-ND 4.0'),
      new(id: 'CC-BY-NC-4.0', label: 'CC BY-NC 4.0'),
      new(id: 'CC-BY-NC-SA-4.0', label: 'CC BY-NC-SA 4.0'),
      new(id: 'CC-BY-NC-ND-4.0', label: 'CC BY-NC-ND 4.0'),
      new(id: 'PDDL-1.0', label: 'PDDL'),
      new(id: 'ODC-By-1.0', label: 'ODC by Attribution'),
      new(id: 'ODbL-1.0', label: 'ODC-ODbl'),
      new(id: 'Apache-2.0', label: 'Apache 2.0'),
      new(id: 'MIT', label: 'MIT'),
      new(id: 'BSD-2-Clause', label: 'BSD 2-clause'),
      new(id: 'BSD-3-Clause', label: 'BSD 3-clause'),
      new(id: 'GPL-3.0-only', label: 'GPL v3'),
      new(id: 'GPL-2.0-only', label: 'GPL v2'),
      new(id: 'LGPL-3.0-only', label: 'LGPL-3.0-only'),
      new(id: 'none', label: 'none')
    ]
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
