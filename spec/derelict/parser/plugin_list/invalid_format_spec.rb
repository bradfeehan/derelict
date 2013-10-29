require "spec_helper"

describe Derelict::Parser::PluginList::InvalidFormat do
  it "is autoloaded" do
    should be_a Derelict::Parser::PluginList::InvalidFormat
  end

  context "when using default reason" do
    its(:message) { should eq "Output from 'vagrant plugin list' was in an unexpected format" }
  end

  context "when using custom reason" do
    subject { Derelict::Parser::PluginList::InvalidFormat.new "reason" }
    its(:message) { should eq "Output from 'vagrant plugin list' was in an unexpected format: reason" }
  end
end
