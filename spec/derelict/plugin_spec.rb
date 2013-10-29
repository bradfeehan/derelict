require "spec_helper"

describe Derelict::Plugin do
  let(:name) { double("name") }
  let(:version) { double("version") }
  let(:plugin) { Derelict::Plugin.new name, version }
  subject { plugin }

  it "is autoloaded" do
    should be_a Derelict::Plugin
  end

  its(:name) { should be name }
  its(:version) { should be version }

  context "when comparing to an equivalent" do
    let(:other) { plugin.dup }

    it { should eq other }
    its(:hash) { should eq other.hash }

    specify "#eql?(other) should be true" do
      expect(subject.eql? other).to be true
    end
  end

  context "when comparing to a non-equivalent" do
    let(:other) { plugin.class.new "not_foo", "1.0" }

    it { should_not eq other }
    its(:hash) { should_not eq other.hash }

    specify "#eql?(other) should be false" do
      expect(subject.eql? other).to be false
    end
  end
end
