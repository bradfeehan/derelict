require "spec_helper"

describe Derelict do
  describe "#instance" do
    let(:instance) { double("instance") }
    before {
      expect(Derelict::Instance).to receive(:new).and_return(instance)
      expect(instance).to receive(:validate!).and_return(instance)
    }

    subject { Derelict.instance }
    it { should be instance }

    include_context "logged messages"
    let(:expected_logs) {[
      " INFO derelict: Creating and validating new instance for '/Applications/Vagrant'\n"
    ]}
  end
end
