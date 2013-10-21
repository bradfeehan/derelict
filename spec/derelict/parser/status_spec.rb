require "spec_helper"

describe Derelict::Parser::Status do
  subject { Derelict::Parser::Status.new output }
  let(:output) { nil }

  it "is autoloaded" do
    should be_a Derelict::Parser::Status
  end

  context "with valid output" do
    let(:output) {
      <<-END.gsub /^ +/, ""
        Current machine states:

        foo                       not created (virtualbox)

        The environment has not yet been created. Run `vagrant up` to
        create the environment. If a machine is not created, only the
        default provider will be shown. So if a provider is not listed,
        then the machine is not created for that environment.
      END
    }

    describe "#vm_names" do
      subject { Derelict::Parser::Status.new(output).vm_names }
      it { should eq Set[:foo] }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing states from VM list using Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing VM list from output using Derelict::Parser::Status instance\n",
      ]}
    end

    describe "#exists?" do
      it "should return true for 'foo' VM" do
        expect(subject.exists?(:foo)).to be true
      end

      it "should return false for unknown VM" do
        expect(subject.exists?(:bar)).to be false
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
      ]}
    end

    describe "#state" do
      it "should return :not_created for 'foo' VM" do
        expect(subject.state(:foo)).to be :not_created
      end

      it "should return :not_created for unknown VM" do
        type = Derelict::VirtualMachine::NotFound
        expect { subject.state(:bar) }.to raise_error type
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
      ]}
    end
  end

  context "with multi-machine output" do
    let(:output) {
      <<-END.gsub /^ +/, ""
        Current machine states:

        foo                       not created (virtualbox)
        bar                       not created (virtualbox)

        This environment represents multiple VMs. The VMs are all listed
        above with their current state. For more information about a specific
        VM, run `vagrant status NAME`.
      END
    }

    describe "#vm_names" do
      subject { Derelict::Parser::Status.new(output).vm_names }
      it { should eq Set[:foo, :bar] }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing states from VM list using Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing VM list from output using Derelict::Parser::Status instance\n",
      ]}
    end

    describe "#exists?" do
      it "should return true for 'foo' VM" do
        expect(subject.exists?(:foo)).to be true
      end

      it "should return true for 'bar' VM" do
        expect(subject.exists?(:bar)).to be true
      end

      it "should return false for unknown VM" do
        expect(subject.exists?(:baz)).to be false
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
      ]}
    end

    describe "#state" do
      it "should return :not_created for 'foo' VM" do
        expect(subject.state(:foo)).to be :not_created
      end

      it "should return :not_created for 'bar' VM" do
        expect(subject.state(:bar)).to be :not_created
      end

      it "should return :not_created for unknown VM" do
        type = Derelict::VirtualMachine::NotFound
        expect { subject.state(:baz) }.to raise_error type
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
      ]}
    end
  end


  context "with invalid list format" do
    let(:output) {
      <<-END.gsub /^ +/, ""
        This output is missing the list of virtual machines.
      END
    }

    describe "#vm_names" do
      subject { Derelict::Parser::Status.new(output).vm_names }
      it "should raise InvalidFormat" do
        type = Derelict::Parser::Status::InvalidFormat
        message = [
          "Output from 'vagrant status' was in an unexpected format: ",
          "Couldn't find list of VMs",
        ].join
        expect { subject }.to raise_error type, message
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing states from VM list using Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing VM list from output using Derelict::Parser::Status instance\n",
        " WARN status: List parsing failed for Derelict::Parser::Status instance: Output from 'vagrant status' was in an unexpected format: Couldn't find list of VMs\n",
        " WARN status: State parsing failed for Derelict::Parser::Status instance: Output from 'vagrant status' was in an unexpected format: Couldn't find list of VMs\n",
      ]}
    end

    describe "#state" do
      subject { Derelict::Parser::Status.new(output).state(:foo) }
      it "should raise InvalidFormat" do
        type = Derelict::Parser::Status::InvalidFormat
        message = [
          "Output from 'vagrant status' was in an unexpected format: ",
          "Couldn't find list of VMs",
        ].join
        expect { subject }.to raise_error type, message
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG status: Successfully initialized Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing states from VM list using Derelict::Parser::Status instance\n",
        "DEBUG status: Parsing VM list from output using Derelict::Parser::Status instance\n",
        " WARN status: List parsing failed for Derelict::Parser::Status instance: Output from 'vagrant status' was in an unexpected format: Couldn't find list of VMs\n",
        " WARN status: State parsing failed for Derelict::Parser::Status instance: Output from 'vagrant status' was in an unexpected format: Couldn't find list of VMs\n",
      ]}
    end
  end

  context "with invalid VM format" do
    let(:output) {
      <<-END.gsub /^ +/, ""
        Current machine states:

        foo                       this line is missing brackets!
        bar                       not created (virtualbox)

        This environment represents multiple VMs. The VMs are all listed
        above with their current state. For more information about a specific
        VM, run `vagrant status NAME`.
      END
    }

    describe "#vm_names" do
      subject { Derelict::Parser::Status.new(output).vm_names }
      it "should raise InvalidFormat" do
        type = Derelict::Parser::Status::InvalidFormat
        message = "Output from 'vagrant status' was in an unexpected format: Couldn't parse VM list"
        expect { subject.parse! }.to raise_error type, message
      end
    end

    describe "#state" do
      subject { Derelict::Parser::Status.new(output).state(:foo) }
      it "should raise InvalidFormat" do
        type = Derelict::Parser::Status::InvalidFormat
        message = "Output from 'vagrant status' was in an unexpected format: Couldn't parse VM list"
        expect { subject }.to raise_error type, message
      end
    end
  end
end
