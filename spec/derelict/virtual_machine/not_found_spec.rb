require "derelict"

describe Derelict::VirtualMachine::NotFound do
  let(:connection) { double("connection") }
  let(:name) { "foo" }
  let(:exception) { Derelict::VirtualMachine::NotFound.new connection, name }
  subject { exception }

  it "is autoloaded" do
    should be_a Derelict::VirtualMachine::NotFound
  end

  describe "#message" do
    subject { exception.message }

    context "with invalid connection" do
      let(:expected) {
        "Invalid Derelict virtual machine: Virtual machine foo not found"
      }
      it { should eq expected }
    end

    context "with invalid connection" do
      let(:connection) { double("connection", :path => "/foo") }
      let(:expected) {
        [
          "Invalid Derelict virtual machine: Virtual machine ",
          "foo not found in /foo",
        ].join
      }
      it { should eq expected }
    end
  end
end
