# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::ContributorRoleComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }

  context "when person" do
    let(:rendered) { render_inline(described_class.new(form:, visible: true, contributor_type: "person", data_options: {contributors_target: "role"})) }

    it "makes select list for individuals" do
      expected = <<~HTML
        <select class="form-select" data-contributors-target="role" aria-describedby="popover-work.role_term" name="role" id="role"><optgroup label="Individual">
        <option value="Author">Author</option>
        <option value="Advisor">Advisor</option>
        <option value="Composer">Composer</option>
        <option value="Contributing author">Contributing author</option>
        <option value="Copyright holder">Copyright holder</option>
        <option value="Creator">Creator</option>
        <option value="Data collector">Data collector</option>
        <option value="Data contributor">Data contributor</option>
        <option value="Editor">Editor</option>
        <option value="Event organizer">Event organizer</option>
        <option value="Interviewee">Interviewee</option>
        <option value="Interviewer">Interviewer</option>
        <option value="Performer">Performer</option>
        <option value="Photographer">Photographer</option>
        <option value="Primary thesis advisor">Primary thesis advisor</option>
        <option value="Principal investigator">Principal investigator</option>
        <option value="Researcher">Researcher</option>
        <option value="Software developer">Software developer</option>
        <option value="Speaker">Speaker</option>
        <option value="Thesis advisor">Thesis advisor</option>
        </optgroup></select>
      HTML

      expect(rendered.to_html).to eq expected.chomp
    end
  end

  context "when hidden person" do
    let(:rendered) { render_inline(described_class.new(form:, visible: false, contributor_type: "person", data_options: {contributors_target: "role"})) }

    it "makes select list for individuals" do
      expected = <<~HTML
        <select disabled hidden="hidden" class="form-select" data-contributors-target="role" aria-describedby="popover-work.role_term" name="role" id="role"><optgroup label="Individual">
        <option value="Author">Author</option>
        <option value="Advisor">Advisor</option>
        <option value="Composer">Composer</option>
        <option value="Contributing author">Contributing author</option>
        <option value="Copyright holder">Copyright holder</option>
        <option value="Creator">Creator</option>
        <option value="Data collector">Data collector</option>
        <option value="Data contributor">Data contributor</option>
        <option value="Editor">Editor</option>
        <option value="Event organizer">Event organizer</option>
        <option value="Interviewee">Interviewee</option>
        <option value="Interviewer">Interviewer</option>
        <option value="Performer">Performer</option>
        <option value="Photographer">Photographer</option>
        <option value="Primary thesis advisor">Primary thesis advisor</option>
        <option value="Principal investigator">Principal investigator</option>
        <option value="Researcher">Researcher</option>
        <option value="Software developer">Software developer</option>
        <option value="Speaker">Speaker</option>
        <option value="Thesis advisor">Thesis advisor</option>
        </optgroup></select>
      HTML

      expect(rendered.to_html).to eq expected.chomp
    end
  end

  context "when organization" do
    let(:rendered) { render_inline(described_class.new(form:, visible: true, contributor_type: "organization", data_options: {contributors_target: "role"})) }

    it "makes select list for organizations" do
      expected = <<~HTML
        <select class="form-select" data-contributors-target="role" aria-describedby="popover-work.role_term" name="role" id="role"><optgroup label="Organization">
        <option value="Author">Author</option>
        <option value="Conference">Conference</option>
        <option value="Contributing author">Contributing author</option>
        <option value="Copyright holder">Copyright holder</option>
        <option value="Data collector">Data collector</option>
        <option value="Data contributor">Data contributor</option>
        <option value="Degree granting institution">Degree granting institution</option>
        <option value="Department">Department</option>
        <option value="Distributor">Distributor</option>
        <option value="Event">Event</option>
        <option value="Event organizer">Event organizer</option>
        <option value="Funder">Funder</option>
        <option value="Host institution">Host institution</option>
        <option value="Issuing body">Issuing body</option>
        <option value="Publisher">Publisher</option>
        <option value="Research group">Research group</option>
        <option value="Sponsor">Sponsor</option>
        </optgroup></select>
      HTML

      expect(rendered.to_html).to eq expected.chomp
    end
  end
end
