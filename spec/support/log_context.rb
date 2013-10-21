require "spec_helper"

# Provides set-up and examples to assert logged messages
#
# Usage:
#
#   * Ensure that the "subject" from the parent context will perform
#     the action which is expected to produce the log messages
#   * Provide a "let(:expected_logs)" block, defining which logs are
#     expected to result from the action performed in the "before"
#     block (otherwise, it defaults to expecting no log messages)
shared_context "logged messages" do
  let(:outputter) { Log4r::Outputter["rspec"] }
  let(:messages) { outputter.messages }

  # Override this let block when including this shared context
  let(:expected_logs) { [] }

  # Add an additional context for readability in the output
  describe "logged messages" do
    before do
      begin
        subject
      rescue Exception
      end
    end

    it "should be an Array" do
      expect(messages).to be_an Array
    end

    it "should contain the expected log messages" do
      expect(messages).to eq expected_logs
    end
  end
end
