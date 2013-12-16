require "spec_helper"

describe Derelict::VirtualMachine do
  let(:connection) { double("connection", :description => "test") }
  let(:name) { double("name", :inspect => "testvm") }

  let(:vm) { Derelict::VirtualMachine.new connection, name }
  subject { vm }

  describe "#initialize" do
    it "should succeed" do
      expect { subject }.to_not raise_error
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
    ]}
  end

  describe "#validate!" do
    before { expect(vm).to receive(:exists?).and_return(exists?) }
    subject { vm.validate! }

    context "when exists? is false" do
      let(:exists?) { false }
      it "should raise NotFound" do
        expect { subject }.to raise_error Derelict::VirtualMachine::NotFound
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        "DEBUG virtualmachine: Starting validation for Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end

    context "when exists? is true" do
      let(:exists?) { true }
      it "shouldn't raise any errors" do
        expect { subject }.to_not raise_error
      end

      it "should be chainable" do
        expect(subject).to be subject
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        "DEBUG virtualmachine: Starting validation for Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Successfully validated Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end
  end

  describe "#exists?" do
    let(:status) { double("status", :exists? => exists?) }
    let(:exists?) { double("exists") }

    before { expect(vm).to receive(:status).and_return(status) }
    subject { vm.exists? }

    it "should delegate to the status parser" do
      expect(subject).to be exists?
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
    ]}
  end

  describe "#state" do
    let(:status) { double("status", :state => state) }
    let(:state) { double("state") }

    before { expect(vm).to receive(:status).and_return(status) }
    subject { vm.state }

    it "should delegate to the status parser" do
      expect(subject).to be state
    end
  end

  describe "#running?" do
    before { expect(vm).to receive(:state).and_return(state) }
    subject { vm.running? }

    context "when state is :running" do
      let(:state) { :running }
      it { should be true }
    end

    context "when state is :foo" do
      let(:state) { :foo }
      it { should be false }
    end
  end

  describe "#up!" do
    let(:options) { Hash.new }
    let(:result) { double("result") }
    subject { vm.up! options }

    context "with too few arguments" do
      before do
        expect(connection).to receive(:execute!).with(:up, name)
      end

      subject { vm.up! }

      it "should not raise ArgumentError" do
        expect { subject }.to_not raise_error
      end
    end

    context "with too many arguments" do
      subject { vm.up! options, :extra }

      it "should raise ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "with correct number of arguments" do
      let(:args) { [:up, name] }

      context "with external logging disabled" do
        before do
          expect(connection).to receive(:execute!).with(*args).and_return result
        end

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
          " INFO virtualmachine: Bringing up Derelict::VirtualMachine 'testvm' from test\n",
        ]}

        context "with different provider" do
          let(:options) { {:provider => "foobar"} }
          let(:args) { [:up, name, "--provider", "foobar"] }

          it { should be result }
        end
      end

      context "with external logging enabled" do
        before do
          expect(connection).to receive(:execute!).with(*args).and_yield("foo", nil).and_return result
        end

        let(:options) { {:log => true} }

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
          " INFO virtualmachine: Bringing up Derelict::VirtualMachine 'testvm' from test\n",
          " INFO external: foo\n",
        ]}

        context "with color enabled" do
          let(:options) { {:log => true, :color => true} }
          let(:args) { [:up, name, '--color'] }
          it { should be result }
        end

        context "in chars mode" do
          let(:options) { {:log => true, :log_mode => :chars} }
          let(:args) { [:up, name, {:mode => :chars}] }
          it { should be result }
        end
      end
    end
  end

  describe "#halt!" do
    let(:options) { Hash.new }
    let(:result) { double("result") }
    subject { vm.halt! options }

    let(:args) { [:halt, name] }
    before do
      expect(connection).to receive(:execute!).with(*args).and_yield("foo", nil).and_return result
    end

    context "with external logging disabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Halting Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end

    context "with external logging enabled" do
      let(:options) { {:log => true} }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Halting Derelict::VirtualMachine 'testvm' from test\n",
        " INFO external: foo\n",
      ]}

      context "with color enabled" do
        let(:options) { {:log => true, :color => true} }
        let(:args) { [:halt, name, '--color'] }
        it { should be result }
      end
    end
  end

  describe "#destroy!" do
    let(:options) { Hash.new }
    let(:result) { double("result") }
    subject { vm.destroy! options }

    let(:args) { [:destroy, name, '--force'] }
    before do
      expect(connection).to receive(:execute!).with(*args).and_yield("foo", nil).and_return result
    end

    context "with external logging disabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Destroying Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end

    context "with external logging enabled" do
      let(:options) { {:log => true} }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Destroying Derelict::VirtualMachine 'testvm' from test\n",
        " INFO external: foo\n",
      ]}

      context "with color enabled" do
        let(:options) { {:log => true, :color => true} }
        let(:args) { [:destroy, name, '--force', '--color'] }
        it { should be result }
      end
    end
  end

  describe "#reload!" do
    let(:options) { Hash.new }
    let(:result) { double("result") }
    subject { vm.reload! options }

    before do
      expect(connection).to receive(:execute!).with(:reload, name).and_yield("foo", nil).and_return result
    end

    context "with external logging disabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Reloading Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end

    context "with external logging enabled" do
      let(:options) { {:log => true} }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Reloading Derelict::VirtualMachine 'testvm' from test\n",
        " INFO external: foo\n",
      ]}
    end
  end

  describe "#suspend!" do
    let(:options) { Hash.new }
    let(:result) { double("result") }
    subject { vm.suspend! options }

    before do
      expect(connection).to receive(:execute!).with(:suspend, name).and_yield("foo", nil).and_return result
    end

    context "with external logging disabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Suspending Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end

    context "with external logging enabled" do
      let(:options) { {:log => true} }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Suspending Derelict::VirtualMachine 'testvm' from test\n",
        " INFO external: foo\n",
      ]}
    end
  end

  describe "#resume!" do
    let(:options) { Hash.new }
    let(:result) { double("result") }
    subject { vm.resume! options }

    before do
      expect(connection).to receive(:execute!).with(:resume, name).and_yield("foo", nil).and_return result
    end

    context "with external logging disabled" do
      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Resuming Derelict::VirtualMachine 'testvm' from test\n",
      ]}
    end

    context "with external logging enabled" do
      let(:options) { {:log => true} }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
        " INFO virtualmachine: Resuming Derelict::VirtualMachine 'testvm' from test\n",
        " INFO external: foo\n",
      ]}
    end
  end

  describe "#status" do
    let(:result) { double("result", :stdout => stdout) }
    let(:stdout) { double("stdout") }
    subject { vm.status }

    before do
      expect(connection).to receive(:execute!).with(:status).and_return(result)
      expect(Derelict::Parser::Status).to receive(:new).with(stdout).and_return(:return_value)
    end

    it "should parse status data from the connection" do
      expect(subject).to be :return_value
    end

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG virtualmachine: Successfully initialized Derelict::VirtualMachine 'testvm' from test\n",
      " INFO virtualmachine: Retrieving Vagrant status for Derelict::VirtualMachine 'testvm' from test\n",
    ]}
  end
end
