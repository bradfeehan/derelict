require "derelict"

describe Derelict::VirtualMachine::NotFound do
  let(:connection) { double("connection", :path => "/foo/bar") }
  subject { Derelict::VirtualMachine::NotFound.new connection, "foo" }

  it "is autoloaded" do
    should be_a Derelict::VirtualMachine::NotFound
  end

  its(:message) {
    should eq [
      "Invalid Derelict virtual machine: ",
      "Virtual machine foo not found in /foo/bar",
    ].join
  }
end
