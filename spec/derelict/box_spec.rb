require "spec_helper"

describe Derelict::Box do
  let(:name) { double("name") }
  let(:provider) { double("provider") }
  let(:box) { Derelict::Box.new name, provider }
  subject { box }

  it "is autoloaded" do
    should be_a Derelict::Box
  end

  its(:name) { should be name }
  its(:provider) { should be provider }

  context "when comparing to an equivalent" do
    let(:other) { box.dup }

    it { should eq other }
    its(:hash) { should eq other.hash }

    specify "#eql?(other) should be true" do
      expect(subject.eql? other).to be true
    end
  end

  context "when comparing to a non-equivalent" do
    let(:other) { box.class.new "not_foo", "other_provider" }

    it { should_not eq other }
    its(:hash) { should_not eq other.hash }

    specify "#eql?(other) should be false" do
      expect(subject.eql? other).to be false
    end
  end
end
