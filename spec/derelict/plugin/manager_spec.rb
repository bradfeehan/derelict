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

  describe "#list" do
    let(:stdout) { "stdout\n" }
    let(:result) { double("result", :stdout => stdout) }
    let(:parser) { double("parser", :plugins => plugins) }
    let(:plugins) { [:foo, :bar] }

    subject { manager.list }

    before do
      expect(instance).to receive(:execute!).with(:plugin, "list").and_return(result)
      expect(Derelict::Parser::PluginList).to receive(:new).with(stdout).and_return(parser)
    end

    it { should be plugins }
  end
end
