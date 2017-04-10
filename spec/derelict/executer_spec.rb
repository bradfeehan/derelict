require "spec_helper"

describe Derelict::Executer do
  let(:executer) { described_class.new }
  let(:command) { double("command") }
  let(:options) { Hash.new }
  let(:block) { Proc.new do end }
  let(:result) { double("result") }

  describe ".execute" do
    before do
      expect(described_class).to receive(:new).with(options).and_return(executer)
      expect(executer).to receive(:execute).with(command, &block).and_return(result)
    end

    subject { described_class.execute command, options, &block }
    it { should be result }
  end

  describe "#initialize" do
    subject { described_class.new options }
    it { should be_a described_class }
    its(:stdout) { should eq "" }
    its(:stderr) { should eq "" }
    its(:success?) { should be_nil }
    its(:status) { should be_nil }

    context "with :chars mode specified" do
      let(:options) { {:mode => :chars} }
      it { should be_a described_class }
    end
  end

  # The way #execute is tested is much slower than a unit test
  # (obviously), but I ran into some difficulty implementing a proper
  # unit test for this method.
  #
  # TODO: rewrite as a unit test
  describe "#execute" do
    subject { executer.execute command, &block }

    context "without a block" do
      let(:command) { "echo 'test 1'" }
      its(:stdout) { should eq "test 1\n" }
      its(:stderr) { should eq "" }
      its(:success?) { should be_true }
      its(:status) { should be 0 }

      context "with non-existent command" do
        let(:command) { "not_actually_a_command" }
        it "should raise ENOENT" do
          expect { subject }.to raise_error(Errno::ENOENT)
        end
      end

      context "with unsuccessful command" do
        let(:command) { "false" }
        its(:success?) { should be_false }
        its(:status) { should be 1 }
      end

      # Unfortunately this part is even worse. It seems to work though!
      # The basic idea is for a thread to kill *this* process once the
      # sub-process has started. It's still relatively fast, and is at
      # least an accurate way to model the real-world use.
      context "when main process is receives a signal" do
        subject {
          Thread.new do
            # Wait for the sub-process to start
            sleep 0.01 while executer.pid.nil?

            # Send SIGINT to this process, it should get forwarded on
            # to the sub-process
            Process.kill "INT", Process.pid
          end

          # Start the sub-process
          executer.execute "sleep 10"
        }

        specify "the sub-process should get killed" do
          expect(subject.success?).to be_false
          expect(subject.status).to be nil
        end
      end
    end

    context "with a block" do
      context "with one argument" do
        let(:command) { "echo 'test 2'" }
        let(:block) do
          @buffer = ""
          Proc.new do |stdout|
            @buffer << stdout
          end
        end

        its(:stdout) { should eq "test 2\n" }
        its(:stderr) { should eq "" }
        its(:success?) { should be_true }
        its(:status) { should be 0 }
        specify "the block should get called" do
          subject; expect(@buffer).to eq executer.stdout
        end
      end

      context "with two arguments" do
        let(:command) { "echo 'test 3'; echo 'test 4' 1>&2" }
        let(:block) do
          @stdout = ""; @stderr = ""
          Proc.new do |stdout, stderr|
            @stdout << stdout unless stdout.nil?
            @stderr << stderr unless stderr.nil?
          end
        end

        its(:stdout) { should eq "test 3\n" }
        its(:stderr) { should eq "test 4\n" }
        its(:success?) { should be_true }
        its(:status) { should be 0 }
        specify "the block should get called" do
          subject
          expect(@stdout).to eq executer.stdout
          expect(@stderr).to eq executer.stderr
        end
      end
    end
  end
end
