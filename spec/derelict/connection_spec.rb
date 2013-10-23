require "spec_helper"

describe Derelict::Connection do
  let(:description) { "the test instance" }
  let(:instance) { double("instance", :description => description) }
  let(:path) { "/baz/qux" }
  let(:connection) { Derelict::Connection.new instance, path }
  subject { connection }

  it "is autoloaded" do
    should be_a Derelict::Connection
  end

  include_context "logged messages"
  let(:expected_logs) {[
    "DEBUG connection: Successfully initialized Derelict::Connection at '/baz/qux' using the test instance\n"
  ]}

  describe "#validate!" do
    subject { connection.validate! }
    let(:exists?) { double("exists?") }
    before do
      expect(File).to receive(:exists?).with(path).and_return(exists?)
    end

    context "with valid data" do
      let(:exists?) { true }
      it { should be connection }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG connection: Successfully initialized Derelict::Connection at '/baz/qux' using the test instance\n",
        "DEBUG connection: Starting validation for Derelict::Connection at '/baz/qux' using the test instance\n",
        " INFO connection: Successfully validated Derelict::Connection at '/baz/qux' using the test instance\n",
      ]}
    end

    context "with invalid data" do
      let(:exists?) { false }
      it "should raise NotFound" do
        expect { subject }.to raise_error Derelict::Connection::NotFound
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG connection: Successfully initialized Derelict::Connection at '/baz/qux' using the test instance\n",
        "DEBUG connection: Starting validation for Derelict::Connection at '/baz/qux' using the test instance\n",
      ]}
    end
  end

  describe "#execute" do
    subject { connection.execute :test, "arg 1" }

    it "should change current working directory first" do
      expect(Dir).to receive(:chdir).with(path).and_return(:foo) # no yield
      expect(instance).to_not receive(:execute)
      expect(subject).to be :foo
    end

    it "should delegate to @instance#execute" do
      expect(Dir).to receive(:chdir).with(path).and_yield
      expect(instance).to receive(:execute).with(:test, "arg 1").and_return(:bar)
      expect(subject).to be :bar
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG connection: Successfully initialized Derelict::Connection at '/baz/qux' using the test instance\n",
      "DEBUG connection: Executing test [\"arg 1\"] on Derelict::Connection at '/baz/qux' using the test instance\n",
    ]}
  end

  describe "#execute!" do
    subject { connection.execute! :test, "arg 1" }

    it "should change current working directory first" do
      expect(Dir).to receive(:chdir).with(path).and_return(:foo) # no yield
      expect(instance).to_not receive(:execute!)
      expect(subject).to be :foo
    end

    it "should delegate to @instance#execute!" do
      expect(Dir).to receive(:chdir).with(path).and_yield
      expect(instance).to receive(:execute!).with(:test, "arg 1").and_return(:bar)
      expect(subject).to be :bar
    end
  end

  describe "#vm" do
    let(:name) { :test }
    let(:vm) { double("vm") }
    before do
      c = Derelict::VirtualMachine
      expect(c).to receive(:new).with(connection, name).and_return(vm)
      expect(vm).to receive(:validate!).and_return(vm)
    end
    subject { connection.vm name }
    it { should be vm }

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG connection: Successfully initialized Derelict::Connection at '/baz/qux' using the test instance\n",
      "DEBUG connection: Retrieving VM 'test' from Derelict::Connection at '/baz/qux' using the test instance\n",
    ]}
  end
end
