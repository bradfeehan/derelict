require "spec_helper"

describe Derelict::Box::Manager do
  let(:instance) { double("instance", :description => "test instance") }
  let(:manager) { Derelict::Box::Manager.new instance }
  subject { manager }

  it "is autoloaded" do
    should be_a Derelict::Box::Manager
  end

  include_context "logged messages"
  let(:expected_logs) {[
    "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n"
  ]}

  describe "#list" do
    let(:stdout) { "stdout\n" }
    let(:result) { double("result", :stdout => stdout) }
    let(:parser) { double("parser", :boxes => boxes) }
    let(:boxes) { [:foo, :bar] }

    subject { manager.list }

    before do
      expect(instance).to receive(:execute!).with(:box, "list").and_return(result)
      expect(Derelict::Parser::BoxList).to receive(:new).with(stdout).and_return(parser)
    end

    it { should be boxes }

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
      " INFO manager: Retrieving Vagrant box list for Derelict::Box::Manager for test instance\n",
    ]}
  end

  describe "#present?" do
    let(:box_name) { double("box_name") }
    let(:box) { double("box", :provider => box_provider) }
    let(:box_provider) { nil }
    let(:provider) { nil }
    subject { manager.present? box_name, provider }

    context "with known box" do
      before { expect(manager).to receive(:fetch).with(box_name, provider).and_return(box) }

      let(:provider) { "provider_one" }
      let(:box_provider) { "provider_one" }
      it { should be true }
    end

    context "with unknown box" do
      before { expect(manager).to receive(:fetch).with(box_name, provider).and_raise(Derelict::Box::NotFound.new box_name, provider) }
      it { should be false }
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
      " INFO manager: Retrieving Vagrant box list for Derelict::Box::Manager for test instance\n",
    ]}
  end

  describe "#add" do
    let(:log) { true }
    let(:box_name) { double("box_name", :to_s => "test box") }
    let(:source) { double("source", :to_s => "test source") }
    let(:result) { double("result") }
    subject { manager.add box_name, source, :log => log }

    before do
      expect(instance).to receive(:execute!).with(:box, "add", box_name, source).and_yield("test").and_return(result)
    end

    it { should be result }

    context "with logging enabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
        " INFO manager: Adding box 'test box' from 'test source' using Derelict::Box::Manager for test instance\n",
        " INFO external: test\n",
      ]}
    end

    context "with logging disabled" do
      let(:log) { false }
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
        " INFO manager: Adding box 'test box' from 'test source' using Derelict::Box::Manager for test instance\n",
      ]}
    end
  end

  describe "#remove" do
    let(:log) { true }
    let(:box_name) { "test_box" }
    let(:provider) { "provider_one" }
    let(:result) { double("result") }
    subject { manager.remove box_name, :provider => provider, :log => log }

    before do
      expect(instance).to receive(:execute!).with(:box, "remove", box_name, provider).and_yield("test").and_return(result)
    end

    it { should be result }

    context "with logging enabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
        " INFO manager: Removing box 'test_box' for 'provider_one' using Derelict::Box::Manager for test instance\n",
        " INFO external: test\n",
      ]}
    end

    context "with logging disabled" do
      let(:log) { false }
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
        " INFO manager: Removing box 'test_box' for 'provider_one' using Derelict::Box::Manager for test instance\n",
      ]}
    end
  end

  describe "#fetch" do
    let(:foo) { double("foo", :name => "foo", :provider => "provider_one") }
    let(:bar) { double("bar", :name => "bar", :provider => "provider_two") }
    let(:boxes) { [foo, bar] }

    let(:box_name) { double("box_name") }
    let(:box_provider) { double("box_provider") }
    subject { manager.fetch box_name, box_provider }
    before { expect(manager).to receive(:list).and_return(boxes) }

    context "with known box" do
      let(:box_name) { "foo" }
      let(:box_provider) { "provider_one" }
      it { should be foo }
    end

    context "with unknown box" do
      let(:box_name) { "qux" }
      it "should raise NotFound" do
        expect { subject }.to raise_error Derelict::Box::NotFound
      end
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG manager: Successfully initialized Derelict::Box::Manager for test instance\n",
    ]}
  end

end
