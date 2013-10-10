require "derelict"

describe Derelict::VirtualMachine do
  let(:connection) { double("connection", :path => "/foo/bar") }
  let(:name) { :name }
  let(:output) { double("output", :stdout => stdout) }
  let(:stdout) { double("stdout") }
  let(:status) { double("status") }

  subject { Derelict::VirtualMachine.new connection, name }

  before {
    expect(connection).to receive(:execute)
      .with(:status)
      .and_return(output)
    expect(output).to receive(:stdout).and_return(stdout)
    expect(Derelict::Parser::Status).to receive(:new)
      .with(stdout)
      .and_return(status)
  }

  context "with valid data" do
    before { expect(status).to receive(:exists?).with(:name).and_return(true) }
    describe "#initialize" do
      it "should succeed" do
        expect { subject }.to_not raise_error
      end

      its(:exists?) { should be true }
      its(:status) { should be status }
    end
  end

  context "with invalid data" do
    before { expect(status).to receive(:exists?).with(:name).and_return(false) }
    describe "#initialize" do
      it "should raise NotFound" do
        expect { subject }.to raise_error Derelict::VirtualMachine::NotFound
      end
    end
  end
end
