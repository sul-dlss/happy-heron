# frozen_string_literal: true

require "rails_helper"

RSpec.describe License do
  describe ".license_list" do
    context "without args" do
      subject(:license_list) { described_class.license_list }

      it "returns array of valid license strings" do
        expect(license_list).to contain_exactly(
          "CC0-1.0",
          "CC-BY-4.0",
          "CC-BY-SA-4.0",
          "CC-BY-ND-4.0",
          "CC-BY-NC-4.0",
          "CC-BY-NC-SA-4.0",
          "CC-BY-NC-ND-4.0",
          "PDDL-1.0",
          "ODC-By-1.0",
          "ODbL-1.0",
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
          "MPL-2.0",
          "none",
          "PDM-1.0"
        )
      end
    end

    context "with include_displayable arg" do
      subject(:license_list) { described_class.license_list(include_displayable: true) }

      it "returns array of valid license strings" do
        expect(license_list).to contain_exactly(
          "CC0-1.0",
          "CC-BY-4.0",
          "CC-BY-SA-4.0",
          "CC-BY-ND-4.0",
          "CC-BY-NC-4.0",
          "CC-BY-NC-SA-4.0",
          "CC-BY-NC-ND-4.0",
          "PDDL-1.0",
          "ODC-By-1.0",
          "ODbL-1.0",
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
          "MPL-2.0",
          "none",
          "PDM-1.0",
          "CC-BY-3.0",
          "CC-BY-SA-3.0",
          "CC-BY-ND-3.0",
          "CC-BY-NC-3.0",
          "CC-BY-NC-SA-3.0",
          "CC-BY-NC-ND-3.0"
        )
      end
    end
  end

  describe ".grouped_options" do
    subject(:grouped_options) { described_class.grouped_options(license) }

    context "without a license" do
      let(:license) { nil }

      it "makes groups with headings" do
        expect(grouped_options).to eq [
          [
            "Creative Commons",
            [
              ["CC0-1.0", "CC0-1.0"],
              ["CC-BY-4.0 Attribution International", "CC-BY-4.0"],
              ["CC-BY-SA-4.0 Attribution-Share Alike International", "CC-BY-SA-4.0"],
              ["CC-BY-ND-4.0 Attribution-No Derivatives International", "CC-BY-ND-4.0"],
              ["CC-BY-NC-4.0 Attribution-NonCommercial International", "CC-BY-NC-4.0"],
              ["CC-BY-NC-SA-4.0 Attribution-NonCommercial-Share Alike International", "CC-BY-NC-SA-4.0"],
              ["CC-BY-NC-ND-4.0 Attribution-NonCommercial-No Derivatives", "CC-BY-NC-ND-4.0"]
            ]
          ],
          [
            "Open Data Commons (ODC) licenses",
            [
              ["PDDL-1.0 Public Domain Dedication and License", "PDDL-1.0"],
              ["ODC-By-1.0 Attribution License", "ODC-By-1.0"],
              ["ODbL-1.0 Open Database License", "ODbL-1.0"]
            ]
          ],
          [
            "Software Licenses",
            [
              ["AGPL-3.0-only GNU Affero General Public License", "AGPL-3.0-only"],
              ["Apache-2.0", "Apache-2.0"],
              ['BSD-2-Clause "Simplified" License', "BSD-2-Clause"],
              ['BSD-3-Clause "New" or "Revised" License', "BSD-3-Clause"],
              ["CDDL-1.1 Common Development and Distribution License", "CDDL-1.1"],
              ["EPL-2.0 Eclipse Public License", "EPL-2.0"],
              ["GPL-3.0-only GNU General Public License", "GPL-3.0-only"],
              ["ISC License", "ISC"],
              ["LGPL-3.0-only Lesser GNU Public License", "LGPL-3.0-only"],
              ["MIT License", "MIT"],
              ["MPL-2.0 Mozilla Public License", "MPL-2.0"]
            ]
          ],
          [
            "Other",
            [
              ["No License", "none"],
              ["Public Domain Mark 1.0", "PDM-1.0"]
            ]
          ]
        ]
      end

      it "does not include the unsupported 3.0 grouping" do
        expect(grouped_options.last).not_to include("Creative Commons 3.0 (Unsupported)")
      end
    end

    context "with an unsupported license" do
      let(:legacy_option) { grouped_options.last }
      let(:license) { "CC-BY-NC-3.0" }

      it "includes the unsupported 3.0 grouping" do
        expect(legacy_option).to include("Creative Commons 3.0 (Unsupported)")
      end

      it "includes the specified license marked as disabled" do
        expect(legacy_option.last).to include(
          ["CC-BY-NC-3.0 Attribution Non Commercial (Unsupported)", license, {disabled: true}]
        )
      end
    end
  end
end
