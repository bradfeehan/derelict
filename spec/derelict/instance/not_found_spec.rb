require "derelict"

describe Derelict::Instance::NotFound do
  subject { Derelict::Instance::NotFound.new "/foo/bar" }

  it "is autoloaded" do
    should be_a Derelict::Instance::NotFound
  end

  its(:message) {
    should eq "Invalid Derelict instance: directory doesn't exist: /foo/bar"
  }
end
