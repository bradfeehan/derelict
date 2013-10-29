require "spec_helper"

describe Derelict::Plugin::NotFound do
  subject { Derelict::Plugin::NotFound.new "test" }

  it "is autoloaded" do
    should be_a Derelict::Plugin::NotFound
  end

  its(:message) {
    should eq "Plugin 'test' is not currently installed"
  }
end
