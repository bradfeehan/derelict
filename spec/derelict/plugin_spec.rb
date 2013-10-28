require "spec_helper"

describe Derelict::Plugin do
  let(:name) { double("name") }
  let(:version) { double("version") }
  let(:plugin) { Derelict::Plugin.new name, version }
  subject { plugin }

  it "is autoloaded" do
    should be_a Derelict::Plugin
  end

  its(:name) { should be name }
  its(:version) { should be version }
end
