require "spec_helper"

describe Derelict::Instance::MissingBinary do
  subject { Derelict::Instance::MissingBinary.new "/foo/bar" }

  it "is autoloaded" do
    should be_a Derelict::Instance::MissingBinary
  end

  its(:message) {
    should eq "Invalid Derelict instance: 'vagrant' binary not found at /foo/bar"
  }
end
