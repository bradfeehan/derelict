require "spec_helper"

describe Derelict::VirtualMachine do
  let(:connection) { double("connection") }
  let(:name) { double("name") }

  let(:vm) { Derelict::VirtualMachine.new connection, name }
  subject { vm }

  describe "#initialize" do
    it "should succeed" do
      expect { subject }.to_not raise_error
    end
  end

  describe "#validate!" do
    before { expect(vm).to receive(:exists?).and_return(exists?) }
    subject { vm.validate! }

    context "when exists? is false" do
      let(:exists?) { false }
      it "should raise NotFound" do
        expect { subject }.to raise_error Derelict::VirtualMachine::NotFound
      end
    end

    context "when exists? is true" do
      let(:exists?) { true }
      it "shouldn't raise any errors" do
        expect { subject }.to_not raise_error
      end

      it "should be chainable" do
        expect(subject).to be subject
      end
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

  describe "#status" do
    let(:result) { double("result", :stdout => stdout) }
    let(:stdout) { double("stdout") }
    subject { vm.status }

    before {
      expect(connection).to receive(:execute!).with(:status).and_return(result)
      expect(Derelict::Parser::Status).to receive(:new).with(stdout).and_return(:return_value)
    }

    it "should parse status data from the connection" do
      expect(subject).to be :return_value
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
end
