require "spec_helper"

describe Derelict::Logger::RawFormatter do
  let(:formatter) { Derelict::Logger::RawFormatter.new }
  subject { formatter }

  it "is autoloaded" do
    should be_a Derelict::Logger::RawFormatter
  end

  describe "#format" do
    let(:data) { double("data") }
    let(:event) { double("event", :data => data) }
    subject { formatter.format event }
    it { should be data }
  end
end
