# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::ContributorRoleComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:, data_options: {contributors_target: "role"})) }

  it "makes groups with headings including Department" do
    expected = <<~HTML
      <select class="form-select" data-contributors-target="role" name="role_term" id="role_term"><optgroup label="Individual">
      <option value="person|Author">Author</option>
      <option value="person|Advisor">Advisor</option>
      <option value="person|Composer">Composer</option>
      <option value="person|Contributing author">Contributing author</option>
      <option value="person|Copyright holder">Copyright holder</option>
      <option value="person|Creator">Creator</option>
      <option value="person|Data collector">Data collector</option>
      <option value="person|Data contributor">Data contributor</option>
      <option value="person|Editor">Editor</option>
      <option value="person|Event organizer">Event organizer</option>
      <option value="person|Interviewee">Interviewee</option>
      <option value="person|Interviewer">Interviewer</option>
      <option value="person|Performer">Performer</option>
      <option value="person|Photographer">Photographer</option>
      <option value="person|Primary thesis advisor">Primary thesis advisor</option>
      <option value="person|Principal investigator">Principal investigator</option>
      <option value="person|Researcher">Researcher</option>
      <option value="person|Software developer">Software developer</option>
      <option value="person|Speaker">Speaker</option>
      <option value="person|Thesis advisor">Thesis advisor</option>
      </optgroup>
      <optgroup label="Organization">
      <option value="organization|Author">Author</option>
      <option value="organization|Conference">Conference</option>
      <option value="organization|Contributing author">Contributing author</option>
      <option value="organization|Copyright holder">Copyright holder</option>
      <option value="organization|Data collector">Data collector</option>
      <option value="organization|Data contributor">Data contributor</option>
      <option value="organization|Degree granting institution">Degree granting institution</option>
      <option value="organization|Department">Department</option>
      <option value="organization|Distributor">Distributor</option>
      <option value="organization|Event">Event</option>
      <option value="organization|Event organizer">Event organizer</option>
      <option value="organization|Funder">Funder</option>
      <option value="organization|Host institution">Host institution</option>
      <option value="organization|Issuing body">Issuing body</option>
      <option value="organization|Publisher">Publisher</option>
      <option value="organization|Research group">Research group</option>
      <option value="organization|Sponsor">Sponsor</option>
      </optgroup></select>
    HTML

    expect(rendered.to_html).to eq expected.chomp
  end
end
