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

  describe "#debug!" do
    let(:enabled) { double("enabled") }
    let(:level) { double("level") }
    let(:logger) { Derelict.logger }
    let(:stderr) { Log4r::Outputter.stderr }

    subject { Derelict.debug! :enabled => enabled, :level => level }

    context "when enabling debug mode" do
      before do
        expect(logger).to receive(:level=).with(level).and_return(nil)
        expect(logger).to receive(:outputters).and_return(Array.new)
        expect(logger).to receive(:add).with(stderr).and_return(logger)
      end

      let(:enabled) { true }
      it { should be Derelict }
    end

    context "when disabling debug mode" do
      before do
        expect(logger).to receive(:level=).with(Log4r::OFF).and_return(nil)
        expect(logger).to receive(:remove).with("stderr").and_return(logger)
      end

      let(:real_level) { Log4r::OFF }
      let(:enabled) { false }
      it { should be Derelict }
    end
  end
end
