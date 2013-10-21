require "spec_helper"

describe Derelict::Utils::Logger::InvalidType do
  subject { Derelict::Utils::Logger::InvalidType.new "test type" }

  it "is autoloaded" do
    should be_a Derelict::Utils::Logger::InvalidType
  end

  its(:message) {
    should eq "Invalid logger type 'test type'"
  }
end
