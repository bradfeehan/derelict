require "spec_helper"

describe Derelict::Parser::BoxList::InvalidFormat do
  it "is autoloaded" do
    should be_a Derelict::Parser::BoxList::InvalidFormat
  end

  context "when using default reason" do
    its(:message) { should eq "Output from 'vagrant box list' was in an unexpected format" }
  end

  context "when using custom reason" do
    subject { Derelict::Parser::BoxList::InvalidFormat.new "reason" }
    its(:message) { should eq "Output from 'vagrant box list' was in an unexpected format: reason" }
  end
end
