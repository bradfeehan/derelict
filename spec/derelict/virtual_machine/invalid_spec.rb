require "spec_helper"

describe Derelict::VirtualMachine::Invalid do
  it "is autoloaded" do
    should be_a Derelict::VirtualMachine::Invalid
  end

  context "when using default reason" do
    its(:message) { should eq "Invalid Derelict virtual machine" }
  end

  context "when using custom reason" do
    subject { Derelict::VirtualMachine::Invalid.new "reason" }
    its(:message) { should eq "Invalid Derelict virtual machine: reason" }
  end
end
