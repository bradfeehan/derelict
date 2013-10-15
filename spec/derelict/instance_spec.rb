require "derelict"

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
      end

      context "with non-existent path" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(false)
        }

        it "should raise NotFound" do
          expect { subject }.to raise_error Derelict::Instance::NotFound
        end
      end

      context "with path pointing to a file" do
        before {
          expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
          expect(File).to receive(:directory?).with("/foo/bar").and_return(false)
        }

        it "should raise NonDirectory" do
          expect { subject }.to raise_error Derelict::Instance::NonDirectory
        end
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
      end
    end

    describe "#execute" do
      let(:arg) { "/foo/bar/bin/vagrant test arg\\ 1" }
      let(:result) {
        double("result", {
          :stdout => "stdout\n",
          :stderr => "stderr\n",
          :success? => true,
        })
      }

      before {
        expect(Shell).to receive(:execute).with(arg).and_return(result)
      }

      subject { instance.execute(:test, "arg 1") }

      its(:stdout) { should eq "stdout\n" }
      its(:stderr) { should eq "stderr\n" }
      its(:success?) { should be true }
    end
  end
end
