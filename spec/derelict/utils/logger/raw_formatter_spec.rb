require "spec_helper"

describe Derelict::Utils::Logger::RawFormatter do
  let(:formatter) { Derelict::Utils::Logger::RawFormatter.new }
  subject { formatter }

  it "is autoloaded" do
    should be_a Derelict::Utils::Logger::RawFormatter
  end

  describe "#format" do
    let(:data) { double("data") }
    let(:event) { double("event", :data => data) }
    subject { formatter.format event }
    it { should be data }
  end
end
