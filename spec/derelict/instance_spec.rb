require "spec_helper"

describe Derelict::Instance do
  let(:instance) { Derelict::Instance.new path }
  let(:path) { nil }

  subject { instance }

  it "is autoloaded" do
    should be_a Derelict::Instance
  end

  describe "#version" do
    let(:result) { double("result", :stdout => stdout) }
    let(:stdout) { double("stdout") }
    let(:parser) { double("parser", :version => "the version") }
    subject { instance.version }
    before {
      expect(instance).to receive(:execute!).with("--version").and_return(result)
      expect(Derelict::Parser::Version).to receive(:new).with(stdout).and_return(parser)
    }

    it "should execute --version and parse the result" do
      expect(subject).to eq "the version"
    end
  end

  describe "#plugins" do
    subject { instance.plugins }
    it { should be_a Derelict::Plugin::Manager }
    its(:instance) { should be instance }
  end

  describe "#boxes" do
    subject { instance.boxes }
    it { should be_a Derelict::Box::Manager }
    its(:instance) { should be instance }
  end

  context "with path parameter" do
    let(:path) { "/foo/bar" }

    describe "#initialize" do
      its(:path) { should eq "/foo/bar" }
    end

    describe "#validate!" do
      subject { instance.validate! }

      context "with valid path" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
          expect(File).to receive(:directory?).with("/foo/bar").and_return(true)
          expect(File).to receive(:exists?).with("/foo/bar/bin/vagrant").and_return(true)
          expect(File).to receive(:executable?).with("/foo/bar/bin/vagrant").and_return(true)
        }

        it "shouldn't raise any exceptions" do
          expect { subject }.to_not raise_error
        end

        it "should be chainable" do
          expect(subject).to be_a Derelict::Instance
        end

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Starting validation for Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Vagrant binary for Derelict::Instance at '/foo/bar' is '/foo/bar/bin/vagrant'\n",
          " INFO instance: Successfully validated Derelict::Instance at '/foo/bar'\n",
        ]}
      end

      context "with non-existent path" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(false)
        }

        it "should raise NotFound" do
          expect { subject }.to raise_error Derelict::Instance::NotFound
        end

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Starting validation for Derelict::Instance at '/foo/bar'\n",
        ]}
      end

      context "with path pointing to a file" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
          expect(File).to receive(:directory?).with("/foo/bar").and_return(false)
        }

        it "should raise NonDirectory" do
          expect { subject }.to raise_error Derelict::Instance::NonDirectory
        end

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Starting validation for Derelict::Instance at '/foo/bar'\n",
        ]}
      end

      context "with vagrant binary missing" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
          expect(File).to receive(:directory?).with("/foo/bar").and_return(true)
          expect(File).to receive(:exists?).with("/foo/bar/bin/vagrant").and_return(false)
        }

        it "should raise MissingBinary" do
          expect { subject }.to raise_error Derelict::Instance::MissingBinary
        end

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Starting validation for Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Vagrant binary for Derelict::Instance at '/foo/bar' is '/foo/bar/bin/vagrant'\n",
        ]}
      end

      context "with vagrant binary non-executable" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
          expect(File).to receive(:directory?).with("/foo/bar").and_return(true)
          expect(File).to receive(:exists?).with("/foo/bar/bin/vagrant").and_return(true)
          expect(File).to receive(:executable?).with("/foo/bar/bin/vagrant").and_return(false)
        }

        it "should raise MissingBinary" do
          expect { subject }.to raise_error Derelict::Instance::MissingBinary
        end

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Starting validation for Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Vagrant binary for Derelict::Instance at '/foo/bar' is '/foo/bar/bin/vagrant'\n",
        ]}
      end
    end

    describe "#connect" do
      let(:connection) { double("connection") }
      let(:connection_path) { double("connection_path", :inspect => "connection_path") }
      subject { instance.connect connection_path }
      before do
        con = Derelict::Connection
        args = [instance, connection_path]
        expect(con).to receive(:new).with(*args).and_return(connection)
        expect(connection).to receive(:validate!).and_return(connection)
      end

      it { should be connection }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
        " INFO instance: Creating connection for 'connection_path' by Derelict::Instance at '/foo/bar'\n",
      ]}
    end

    context "with mock Executer" do
      let(:expected_command) { "/foo/bar/bin/vagrant test arg\\ 1" }
      before do
        expect(Derelict::Executer).to receive(:execute).with(expected_command, options).and_return(result)
      end

      let(:options) { Hash.new }

      let(:result) do
        double("result", {
          :stdout => "stdout\n",
          :stderr => "stderr\n",
          :success? => success,
        })
      end

      let(:success) { double("success") }

      describe "#execute" do
        subject { instance.execute :test, "arg 1" }
        its(:stdout) { should eq "stdout\n" }
        its(:stderr) { should eq "stderr\n" }
        its(:success?) { should be success }

        include_context "logged messages"
        let(:expected_logs) {[
          "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
          "DEBUG instance: Vagrant binary for Derelict::Instance at '/foo/bar' is '/foo/bar/bin/vagrant'\n",
          "DEBUG instance: Generated command '/foo/bar/bin/vagrant test arg\\ 1' from subcommand 'test' with arguments [\"arg 1\"]\n",
          "DEBUG instance: Executing /foo/bar/bin/vagrant test arg\\ 1 using Derelict::Instance at '/foo/bar'\n",
        ]}

        context "with options hash" do
          let(:options) { {:foo => :bar} }
          subject { instance.execute :test, "arg 1", options }
          its(:stdout) { should eq "stdout\n" }
          its(:stderr) { should eq "stderr\n" }
          its(:success?) { should be success }
        end

        context "with :sudo option enabled" do
          let(:options_argument) { {:sudo => true} }
          let(:options) { Hash.new } # Don't pass sudo opt to Executer.execute
          let(:expected_command) { "sudo -- /foo/bar/bin/vagrant test arg\\ 1" }
          subject { instance.execute :test, "arg 1", options_argument }
          its(:stdout) { should eq "stdout\n" }
          its(:stderr) { should eq "stderr\n" }
          its(:success?) { should be success }
        end
      end

      describe "#execute!" do
        subject { instance.execute! :test, "arg 1" }

        context "on success" do
          let(:success) { true }

          its(:stdout) { should eq "stdout\n" }
          its(:stderr) { should eq "stderr\n" }
          its(:success?) { should be true }

          include_context "logged messages"
          let(:expected_logs) {[
            "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
            "DEBUG instance: Vagrant binary for Derelict::Instance at '/foo/bar' is '/foo/bar/bin/vagrant'\n",
            "DEBUG instance: Generated command '/foo/bar/bin/vagrant test arg\\ 1' from subcommand 'test' with arguments [\"arg 1\"]\n",
            "DEBUG instance: Executing /foo/bar/bin/vagrant test arg\\ 1 using Derelict::Instance at '/foo/bar'\n",
          ]}
        end

        context "on failure" do
          let(:success) { false }

          it "should raise CommandFailed" do
            expect { subject }.to raise_error Derelict::Instance::CommandFailed
          end

          include_context "logged messages"
          let(:expected_logs) {[
            "DEBUG instance: Successfully initialized Derelict::Instance at '/foo/bar'\n",
            "DEBUG instance: Vagrant binary for Derelict::Instance at '/foo/bar' is '/foo/bar/bin/vagrant'\n",
            "DEBUG instance: Generated command '/foo/bar/bin/vagrant test arg\\ 1' from subcommand 'test' with arguments [\"arg 1\"]\n",
            "DEBUG instance: Executing /foo/bar/bin/vagrant test arg\\ 1 using Derelict::Instance at '/foo/bar'\n",
            "DEBUG instance: Generated command '/foo/bar/bin/vagrant test arg\\ 1' from subcommand 'test' with arguments [\"arg 1\"]\n",
            " WARN instance: Command /foo/bar/bin/vagrant test arg\\ 1 failed: Error executing Vagrant command '/foo/bar/bin/vagrant test arg\\ 1', STDERR output:\nstderr\n\n",
          ]}
        end
      end
    end
  end
end
