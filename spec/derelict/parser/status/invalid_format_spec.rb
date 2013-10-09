require "derelict"

describe Derelict::Parser::Status::InvalidFormat do
  it "is autoloaded" do
    should be_a Derelict::Parser::Status::InvalidFormat
  end

  context "when using default reason" do
    its(:message) { should eq "Output from 'vagrant status' was in an unexpected format" }
  end

  context "when using custom reason" do
    subject { Derelict::Parser::Status::InvalidFormat.new "reason" }
    its(:message) { should eq "Output from 'vagrant status' was in an unexpected format: reason" }
  end
end
