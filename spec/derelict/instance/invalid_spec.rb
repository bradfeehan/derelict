require "spec_helper"

describe Derelict::Instance::Invalid do
  it "is autoloaded" do
    should be_a Derelict::Instance::Invalid
  end

  context "when using default reason" do
    its(:message) { should eq "Invalid Derelict instance" }
  end

  context "when using custom reason" do
    subject { Derelict::Instance::Invalid.new "reason" }
    its(:message) { should eq "Invalid Derelict instance: reason" }
  end
end
