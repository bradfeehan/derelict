require "spec_helper"

describe Derelict::Plugin::Manager do
  let(:instance) { double("instance", :description => "test instance") }
  let(:manager) { Derelict::Plugin::Manager.new instance }
  subject { manager }

  it "is autoloaded" do
    should be_a Derelict::Plugin::Manager
  end

  include_context "logged messages"
  let(:expected_logs) {[
    "DEBUG manager: Successfully initialized Derelict::Plugin::Manager for test instance\n"
  ]}
end
