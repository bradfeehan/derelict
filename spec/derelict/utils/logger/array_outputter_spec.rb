require "spec_helper"

describe Derelict::Utils::Logger::ArrayOutputter do
  let(:logger) { Log4r::Logger.new "test::array_outputter_spec" }
  let(:outputter) { Derelict::Utils::Logger::ArrayOutputter.new "test" }
  before { logger.outputters = [outputter] }
  subject { outputter }

  describe "#level" do
    subject { outputter.level }
    it { should be Log4r::ALL }
  end

  context "with no data" do
    describe "#messages" do
      subject { outputter.messages }
      it { should eq [] }
    end

    describe "#flush" do
      subject { outputter.flush }
      it { should eq [] }
    end
  end

  context "after INFO level log" do
    before { logger.info "test info message" }
    let(:message) { " INFO array_outputter_spec: test info message\n" }

    describe "#messages" do
      subject { outputter.messages }
      it { should eq [message] }
    end

    context "then #flush" do
      subject { outputter.flush }
      it { should eq [message] }
    end
  end
end
