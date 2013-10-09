require "derelict"

describe Derelict::Parser do
  let(:output) { nil }
  subject { Derelict::Parser.new output }

  it "is autoloaded" do
    should be_a Derelict::Parser
  end

  describe "#initialize" do
    let(:output) { "the output" }

    it "should store output" do
      expect(subject.output).to eq "the output"
    end
  end
end
