require "derelict"

describe Derelict::Instance do
  it "is autoloaded" do
    should be_a Derelict::Instance
  end

  context "with existent directory" do
    subject { Derelict::Instance.new "/foo/bar" }
    before {
      expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
      expect(File).to receive(:directory?).with("/foo/bar").and_return(true)
      expect(File).to receive(:exists?).with("/foo/bar/bin/vagrant").and_return(true)
      expect(File).to receive(:executable?).with("/foo/bar/bin/vagrant").and_return(true)
    }

    describe "#initialize" do
      it "shouldn't raise an exception" do
        expect { subject }.to_not raise_error
      end

      its(:path) { should eq "/foo/bar" }
    end
  end

  context "with non-existent directory" do
    subject { Derelict::Instance.new "/foo/bar" }
    before {
      expect(File).to receive(:exists?).with("/foo/bar").and_return(false)
    }

    describe "#initialize" do
      it "should raise NotFound" do
        expect { subject }.to raise_error Derelict::Instance::NotFound
      end
    end
  end

  context "with path pointing to a file" do
    subject { Derelict::Instance.new "/foo/bar" }
    before {
      expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
      expect(File).to receive(:directory?).with("/foo/bar").and_return(false)
    }

    describe "#initialize" do
      it "should raise NonDirectory" do
        expect { subject }.to raise_error Derelict::Instance::NonDirectory
      end
    end
  end

  context "with vagrant binary missing" do
    subject { Derelict::Instance.new "/foo/bar" }
    before {
      expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
      expect(File).to receive(:directory?).with("/foo/bar").and_return(true)
      expect(File).to receive(:exists?).with("/foo/bar/bin/vagrant").and_return(false)
    }

    describe "#initialize" do
      it "should raise MissingBinary" do
        expect { subject }.to raise_error Derelict::Instance::MissingBinary
      end
    end
  end

  context "with vagrant binary non-executable" do
    subject { Derelict::Instance.new "/foo/bar" }
    before {
      expect(File).to receive(:exists?).with("/foo/bar").and_return(true)
      expect(File).to receive(:directory?).with("/foo/bar").and_return(true)
      expect(File).to receive(:exists?).with("/foo/bar/bin/vagrant").and_return(true)
      expect(File).to receive(:executable?).with("/foo/bar/bin/vagrant").and_return(false)
    }

    describe "#initialize" do
      it "should raise MissingBinary" do
        expect { subject }.to raise_error Derelict::Instance::MissingBinary
      end
    end
  end
end
