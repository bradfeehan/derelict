require "derelict"

describe Derelict::Instance::CommandFailed do
  it "is autoloaded" do
    should be_a Derelict::Instance::CommandFailed
  end

  describe "#initialize" do
    let(:command) { nil }
    let(:result) { nil }
    subject { Derelict::Instance::CommandFailed.new command, result }

    context "with no arguments" do
      its(:message) { should eq "Error executing Vagrant command" }
    end

    context "with custom command" do
      let(:command) { "my_command" }
      its(:message) { should eq "Error executing Vagrant command 'my_command'" }
    end

    context "with custom result" do
      let(:result) { double("result", :stderr => "my_stderr") }
      its(:message) {
        should eq "Error executing Vagrant command, STDERR output:\nmy_stderr"
      }
    end

    context "with custom command and result" do
      let(:command) { "my_command" }
      let(:result) { double("result", :stderr => "my_stderr") }
      its(:message) {
        should eq [
          "Error executing Vagrant command 'my_command', ",
          "STDERR output:\nmy_stderr"
        ].join
      }
    end
  end
end
