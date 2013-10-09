require "derelict"

describe Derelict::Connection::Invalid do
  it "is autoloaded" do
    should be_a Derelict::Connection::Invalid
  end

  context "when using default reason" do
    its(:message) { should eq "Invalid Derelict connection" }
  end

  context "when using custom reason" do
    subject { Derelict::Connection::Invalid.new "reason" }
    its(:message) { should eq "Invalid Derelict connection: reason" }
  end
end
