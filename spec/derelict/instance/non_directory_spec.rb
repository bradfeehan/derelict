require "derelict"

describe Derelict::Instance::NonDirectory do
  subject { Derelict::Instance::NonDirectory.new "/foo/bar" }

  it "is autoloaded" do
    should be_a Derelict::Instance::NonDirectory
  end

  its(:message) {
    should eq "Invalid Derelict instance: expected directory, found file: /foo/bar"
  }
end
