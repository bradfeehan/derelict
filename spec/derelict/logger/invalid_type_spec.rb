require "spec_helper"

describe Derelict::Logger::InvalidType do
  subject { Derelict::Logger::InvalidType.new "test type" }

  it "is autoloaded" do
    should be_a Derelict::Logger::InvalidType
  end

  its(:message) {
    should eq "Invalid logger type 'test type'"
  }
end
