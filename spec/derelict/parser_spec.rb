require "spec_helper"

describe Derelict::Parser do
  let(:output) { nil }
  subject { Derelict::Parser.new output }

  it "is autoloaded" do
    should be_a Derelict::Parser
  end

  describe "#initialize" do
    let(:output) { "the output" }
    let(:description) { "test parser" }

    it "should store output" do
      expect(subject.output).to eq "the output"
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG parser: Successfully initialized Derelict::Parser (unknown type)\n",
    ]}
  end
end
