require "spec_helper"

describe Derelict::Box::NotFound do
  subject { Derelict::Box::NotFound.new "test", "provider_one" }

  it "is autoloaded" do
    should be_a Derelict::Box::NotFound
  end

  its(:message) {
    should eq "Box 'test' for provider 'provider_one' missing"
  }
end
