require "derelict"

describe Derelict::Connection do
  let(:instance) { double('instance') }
  let(:path) { double('path') }
  subject { Derelict::Connection.new instance, path }

  it "is autoloaded" do
    should be_a Derelict::Connection
  end

  describe "#execute" do
    it "should change current working directory first" do
      expect(Dir).to receive(:chdir).with(path) # no yield
      expect(instance).to_not receive(:execute)
      subject.execute :test
    end

    it "should delegate to @instance#execute" do
      expect(Dir).to receive(:chdir).with(path).and_yield
      expect(instance).to receive(:execute).with(:test)
      subject.execute :test
    end
  end
end
