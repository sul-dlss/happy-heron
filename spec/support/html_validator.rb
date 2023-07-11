# frozen_string_literal: true

# Use Nokogiri to validate HTML
RSpec::Matchers.define :be_valid_html do
  match do |actual_html|
    # The `-1` value tells Nokogiri to return *all* HTML5 parse errors`
    @html_errors = Nokogiri::HTML5(actual_html, max_errors: -1).errors
    @html_errors.empty?
  end

  failure_message do
    "expected no HTML parsing errors and found #{@html_errors.count}:\n\t#{@html_errors.map(&:detailed_message).join("\n\t")}"
  end
end
