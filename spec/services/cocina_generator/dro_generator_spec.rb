# frozen_string_literal: true

require "rails_helper"

RSpec.describe CocinaGenerator::DROGenerator do
  let(:collection) { build(:collection, druid: "druid:bc123df4567") }
  let(:model) { described_class.generate_model(work_version:, cocina_obj:) }
  let(:cocina_obj) { nil }
  let(:project_tag) { Settings.h2.project_tag }
  let(:types_form) do
    [
      {
        source: {
          value: "Stanford self-deposit resource types"
        },
        structuredValue: [
          {
            type: "type",
            value: "Text"
          },
          {
            type: "subtype",
            value: "Code"
          },
          {
            type: "subtype",
            value: "Oral history"
          }
        ],
        type: "resource type"
      },
      {
        source: {
          code: "marcgt"
        },
        type: "genre",
        uri: "http://id.loc.gov/vocabulary/marcgt/com",
        value: "computer program"
      },
      {
        type: "genre",
        value: "Oral histories",
        uri: "http://id.loc.gov/authorities/genreForms/gf2011026431",
        source: {
          code: "lcgft"
        }
      },
      {
        source: {
          value: "MODS resource types"
        },
        type: "resource type",
        value: "text"
      },
      {
        value: "Text",
        type: "resource type",
        source: {
          value: "DataCite resource types"
        }
      }
    ]
  end
  let(:admin_metadata) do
    {
      event: [
        {
          type: "creation",
          date: [
            {
              value: "2007-02-10",
              encoding: {
                code: "edtf"
              }
            }
          ]
        }
      ],
      note: [
        {
          value: "Metadata created by user via Stanford self-deposit application",
          type: "record origin"
        }
      ]
    }
  end
  let(:license_uri) { License.find("CC0-1.0").uri }

  context "when files are not present" do
    context "without a cocina_obj" do
      let(:work_version) do
        build(:work_version, work_type: "text", work:, title: "Test title")
      end
      let(:work) { build(:work, id: 7, collection:) }
      let(:expected_model) do
        Cocina::Models::RequestDRO.new(
          {
            type: Cocina::Models::ObjectType.object,
            label: "Test title",
            version: 1,
            access: {
              view: "world",
              download: "world",
              license: license_uri,
              useAndReproductionStatement: Settings.access.use_and_reproduction_statement
            },
            administrative: {
              hasAdminPolicy: "druid:zx485kb6348",
              partOfProject: project_tag
            },
            description: {
              title: [
                {
                  value: "Test title"
                }
              ],
              note: [
                {
                  value: "test abstract",
                  type: "abstract"
                },
                {
                  value: "test citation",
                  type: "preferred citation"
                }
              ],
              form: types_form,
              adminMetadata: admin_metadata
            },
            identification: {
              sourceId: "hydrus:object-#{work_version.work.id}"
            },
            structural: {
              contains: [],
              isMemberOf: [collection.druid]
            }
          }
        )
      end

      it "generates the model" do
        expect(model.to_h).to eq(expected_model.to_h)
      end
    end
  end

  context "with a cocina_obj, assign_doi is false" do
    let(:work_version) do
      build(:work_version, work_type: "text", title: "Test title", work:)
    end
    let(:work) { build(:work, id: 7, druid: "druid:bk123gh4567", collection:) }
    let(:cocina_obj) do
      Cocina::RSpec::Factories.build(:dro_with_metadata, id: "druid:bk123gh4567")
    end

    let(:expected_model) do
      Cocina::Models::DRO.new(
        {
          externalIdentifier: "druid:bk123gh4567",
          type: Cocina::Models::ObjectType.object,
          label: "Test title",
          version: 1,
          access: {
            view: "world",
            download: "world",
            license: license_uri,
            useAndReproductionStatement: Settings.access.use_and_reproduction_statement
          },
          administrative: {
            hasAdminPolicy: "druid:zx485kb6348"
          },
          description: {
            title: [
              {
                value: "Test title"
              }
            ],
            note: [
              {
                value: "test abstract",
                type: "abstract"
              },
              {
                value: "test citation",
                type: "preferred citation"
              }
            ],
            form: types_form,
            purl: "https://purl.stanford.edu/bk123gh4567",
            adminMetadata: admin_metadata
          },
          identification: {
            sourceId: "hydrus:object-#{work_version.work.id}"
          },
          structural: {
            contains: [],
            isMemberOf: [collection.druid]
          }
        }
      )
    end

    before do
      allow(work).to receive(:assign_doi?).and_return(false)
    end

    it "generates the model" do
      expect(model.to_h).to eq expected_model.to_h
    end
  end

  context "with a doi" do
    let(:work_version) do
      build(:work_version, work_type: "text", title: "Test title", work:)
    end
    let(:work) { build(:work, id: 7, druid: "druid:bk123gh4567", doi: "10.80343/bk123gh4567", collection:) }
    let(:cocina_obj) do
      Cocina::RSpec::Factories.build(:dro_with_metadata, id: "druid:bk123gh4567")
    end
    let(:expected_model) do
      Cocina::Models::DRO.new(
        {
          externalIdentifier: "druid:bk123gh4567",
          type: Cocina::Models::ObjectType.object,
          label: "Test title",
          version: 1,
          access: {
            view: "world",
            download: "world",
            license: license_uri,
            useAndReproductionStatement: Settings.access.use_and_reproduction_statement
          },
          administrative: {
            hasAdminPolicy: "druid:zx485kb6348"
          },
          description: {
            title: [
              {
                value: "Test title"
              }
            ],
            note: [
              {
                value: "test abstract",
                type: "abstract"
              },
              {
                value: "test citation",
                type: "preferred citation"
              }
            ],
            form: types_form,
            purl: "https://purl.stanford.edu/bk123gh4567",
            adminMetadata: admin_metadata
          },
          identification: {
            sourceId: "hydrus:object-#{work_version.work.id}",
            doi: "10.80343/bk123gh4567"
          },
          structural: {
            contains: [],
            isMemberOf: [collection.druid]
          }
        }
      )
    end

    it "generates the model" do
      expect(model.to_h).to eq expected_model.to_h
    end
  end

  context "when a doi is requested and there is no druid" do
    let(:work_version) do
      build(:work_version, :version_draft, work_type: "text", title: "Test title", work:)
    end
    let(:work) { build(:work, id: 7, druid: nil, collection:) }
    let(:expected_model) do
      Cocina::Models::RequestDRO.new(
        {
          type: Cocina::Models::ObjectType.object,
          label: "Test title",
          version: 1,
          access: {
            view: "world",
            download: "world",
            license: license_uri,
            useAndReproductionStatement: Settings.access.use_and_reproduction_statement
          },
          administrative: {
            hasAdminPolicy: "druid:zx485kb6348",
            partOfProject: project_tag
          },
          description: {
            title: [
              {
                value: "Test title"
              }
            ],
            note: [
              {
                value: "test abstract",
                type: "abstract"
              },
              {
                value: "test citation",
                type: "preferred citation"
              }
            ],
            form: types_form,
            adminMetadata: admin_metadata
          },
          identification: {
            sourceId: "hydrus:object-#{work_version.work.id}"
          },
          structural: {
            contains: [],
            isMemberOf: [collection.druid]
          }
        }
      )
    end

    it "generates the model" do
      expect(model.to_h).to eq expected_model.to_h
    end
  end

  context "when files are present" do
    let!(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join("spec/fixtures/files/sul.svg").open,
        filename: "sul.svg",
        content_type: "image/svg+xml"
      )
    end
    let!(:blob2) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join("spec/fixtures/files/favicon.ico").open,
        filename: "favicon.ico",
        content_type: "image/svg+xml"
      )
    end
    let(:blob3) do
      ActiveStorage::Blob.create_before_direct_upload!(
        key: attached_file.create_globus_active_storage_key,
        filename: "globus.pdf",
        service_name: ActiveStorage::Service::GlobusService::SERVICE_NAME,
        byte_size: 0,
        checksum: "globus.pdf"
      )
    end
    let(:attached_file) { build(:attached_file, path: "sul.svg") }
    let(:attached_file2) { build(:attached_file, path: "favicon.ico") }
    let(:attached_file3) { build(:attached_file, path: "globus.pdf") }

    before do
      # rubocop:disable RSpec/MessageChain
      allow(attached_file).to receive_message_chain(:file, :blob).and_return(blob)
      allow(attached_file2).to receive_message_chain(:file, :blob).and_return(blob2)
      allow(attached_file3).to receive_message_chain(:file, :blob).and_return(blob3)
      # rubocop:enable RSpec/MessageChain
      allow(work).to receive(:assign_doi?).and_return(false)
    end

    after do
      blob.destroy!
      blob2.destroy!
    end

    context "without a cocina_obj" do
      let(:work_version) do
        build(:work_version, version: 1, attached_files: [attached_file, attached_file2, attached_file3],
          title: "Test title", work:, globus_endpoint: "jstanford/work333/version1")
      end
      let(:work) { build(:work, id: 7, collection:) }

      let(:expected_model) do
        Cocina::Models::RequestDRO.new(
          {
            type: Cocina::Models::ObjectType.object,
            label: "Test title",
            version: 1,
            access: {
              view: "world",
              download: "world",
              license: license_uri,
              useAndReproductionStatement: Settings.access.use_and_reproduction_statement
            },
            administrative: {
              hasAdminPolicy: "druid:zx485kb6348",
              partOfProject: project_tag
            },
            description: {
              title: [
                {
                  value: "Test title"
                }
              ],
              note: [
                {
                  value: "test abstract",
                  type: "abstract"
                },
                {
                  value: "test citation",
                  type: "preferred citation"
                }
              ],
              form: types_form,
              adminMetadata: admin_metadata
            },
            identification: {
              sourceId: "hydrus:object-#{work_version.work.id}"
            },
            structural: {
              contains: [
                {
                  label: "MyString",
                  structural: {contains: [
                    {
                      access: {view: "world", download: "world"},
                      administrative: {publish: true, sdrPreserve: true, shelve: true},
                      filename: "favicon.ico",
                      hasMessageDigests: [
                        {digest: "aa9cf3e587a33b77b6d6ee0f8d36de39", type: "md5"},
                        {digest: "e30e483ba4222573e8952ca066af8d2a1bd0bc53", type: "sha1"}
                      ],
                      hasMimeType: "image/png",
                      label: "MyString",
                      size: 4_045,
                      type: Cocina::Models::ObjectType.file,
                      version: 1
                    }
                  ]},
                  type: Cocina::Models::FileSetType.file,
                  version: 1
                },
                {
                  label: "MyString",
                  structural: {contains: [
                    {
                      access: {view: "world", download: "world"},
                      administrative: {publish: true, sdrPreserve: true, shelve: true},
                      filename: "globus.pdf",
                      hasMessageDigests: [],
                      label: "MyString",
                      type: Cocina::Models::ObjectType.file,
                      version: 1,
                      externalIdentifier: "globus://jstanford/work333/version1/globus.pdf"
                    }
                  ]},
                  type: Cocina::Models::FileSetType.file,
                  version: 1
                },
                {
                  label: "MyString",
                  structural: {contains: [
                    {
                      access: {view: "world", download: "world"},
                      administrative: {publish: true, sdrPreserve: true, shelve: true},
                      filename: "sul.svg",
                      hasMessageDigests: [
                        {digest: "f5eff9e28f154f79f7a11261bc0d4b30", type: "md5"},
                        {digest: "2046f6584c2f0f5e9c0df7e8070d14d1ec65f382", type: "sha1"}
                      ],
                      hasMimeType: "image/svg+xml",
                      label: "MyString",
                      size: 17_675,
                      type: Cocina::Models::ObjectType.file,
                      version: 1
                    }
                  ]},
                  type: Cocina::Models::FileSetType.file,
                  version: 1
                }
              ],
              isMemberOf: [collection.druid]
            }
          }
        )
      end

      it "generates the model" do
        expect(model.to_h).to eq expected_model.to_h
      end
    end

    context "with a cocina_obj" do
      let(:work_version) do
        build(:work_version, version: 1, attached_files: [attached_file], title: "Test title", work:)
      end
      let(:work) { build(:work, id: 7, druid: "druid:bk123gh4567", collection:) }
      let(:cocina_obj) do
        Cocina::RSpec::Factories.build(:dro_with_metadata, id: "druid:bk123gh4567")
      end
      let(:expected_model) do
        Cocina::Models::DRO.new(
          {
            type: Cocina::Models::ObjectType.object,
            label: "Test title",
            version: 1,
            externalIdentifier: "druid:bk123gh4567",
            access: {
              view: "world",
              download: "world",
              license: license_uri,
              useAndReproductionStatement: Settings.access.use_and_reproduction_statement
            },
            administrative: {
              hasAdminPolicy: "druid:zx485kb6348"
            },
            description: {
              title: [
                {
                  value: "Test title"
                }
              ],
              note: [
                {
                  value: "test abstract",
                  type: "abstract"
                },
                {
                  value: "test citation",
                  type: "preferred citation"
                }
              ],
              form: types_form,
              purl: "https://purl.stanford.edu/bk123gh4567",
              adminMetadata: admin_metadata
            },
            identification: {
              sourceId: "hydrus:object-#{work_version.work.id}"
            },
            structural: {
              contains: [
                {
                  label: "MyString",
                  structural: {
                    contains: [
                      {
                        access: {view: "world", download: "world"},
                        administrative: {publish: true, sdrPreserve: true, shelve: true},
                        filename: "sul.svg",
                        hasMessageDigests: [
                          {digest: "f5eff9e28f154f79f7a11261bc0d4b30", type: "md5"},
                          {digest: "2046f6584c2f0f5e9c0df7e8070d14d1ec65f382", type: "sha1"}
                        ],
                        hasMimeType: "image/svg+xml",
                        label: "MyString",
                        size: 17_675,
                        type: Cocina::Models::ObjectType.file,
                        externalIdentifier: "9999999",
                        version: 1
                      }
                    ]
                  },
                  type: Cocina::Models::FileSetType.file,
                  externalIdentifier: "https://cocina.sul.stanford.edu/fileSet/bk123gh4567-123456",
                  version: 1
                }
              ],
              isMemberOf: [collection.druid]
            }
          }
        )
      end

      before do
        allow(SecureRandom).to receive(:uuid).and_return "123456"
        allow(blob).to receive(:signed_id).and_return "9999999"
      end

      it "generates the model" do
        expect(model.to_h).to eq expected_model.to_h
      end
    end
  end
end
