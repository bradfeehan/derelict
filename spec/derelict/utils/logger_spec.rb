require "spec_helper"

describe Derelict::Utils::Logger do
  let(:logger) do
    Module.new do
      extend Derelict::Utils::Logger
      private
        def self.logger_name
          "test"
        end
    end
  end

  describe "#logger" do
    subject { logger.logger options }
    let(:options) { {:type => type} }
    let(:type) { :nil }

    context "internal type" do
      let(:type) { :internal }
      it { should be_a Log4r::Logger }
    end

    context "external type" do
      let(:type) { :external }
      it { should be_a Log4r::Logger }
    end

    context "invalid type" do
      it "should raise InvalidType" do
        expect { subject }.to raise_error Derelict::Utils::Logger::InvalidType
      end
    end
  end
end
