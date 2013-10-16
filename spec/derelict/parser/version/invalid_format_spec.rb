require "spec_helper"

describe Derelict::Parser::Version::InvalidFormat do
  it "is autoloaded" do
    should be_a Derelict::Parser::Version::InvalidFormat
  end

  context "when using default reason" do
    its(:message) { should eq "Output from 'vagrant --version' was in an unexpected format" }
  end

  context "when using custom reason" do
    subject { Derelict::Parser::Version::InvalidFormat.new "reason" }
    its(:message) { should eq "Output from 'vagrant --version' was in an unexpected format: reason" }
  end
end
