require "spec_helper"

describe Derelict::Parser::PluginList::NeedsReinstall do
  let(:output) { double("output") }
  subject { Derelict::Parser::PluginList::NeedsReinstall.new output }

  it "is autoloaded" do
    should be_a Derelict::Parser::PluginList::NeedsReinstall
  end

  its(:message) { should eq "Vagrant plugins installed before upgrading to version 1.4.x need to be uninstalled and re-installed." }
  its(:output) { should be output }
end
