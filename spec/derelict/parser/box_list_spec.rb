require "spec_helper"

describe Derelict::Parser::BoxList do
  subject { Derelict::Parser::BoxList.new output }
  let(:output) { nil }

  it "is autoloaded" do
    should be_a Derelict::Parser::BoxList
  end

  describe "#boxes" do
    subject { Derelict::Parser::BoxList.new(output).boxes }

    include_context "logged messages"
    let(:expected_logs) {[
      "DEBUG boxlist: Successfully initialized Derelict::Parser::BoxList instance\n",
    ]}

    context "with valid output" do
      let(:output) {
        <<-END.gsub /^ +/, ""
          foobar (provider_one)
          baz    (provider_two)
        END
      }

      let(:foobar) { Derelict::Box.new "foobar", "provider_one" }
      let(:baz) { Derelict::Box.new "baz", "provider_two" }
      it { should eq Set[foobar, baz] }
    end

    context "with invalid output" do
      let(:output) {
        <<-END.gsub /^ +/, ""
          foobar (provider_one) lolwut
          baz with no brackets
        END
      }

      it "should raise InvalidFormat" do
        expect { subject }.to raise_error Derelict::Parser::BoxList::InvalidFormat
      end
    end

    context "with no boxes in list" do
      let(:output) {
        <<-END.gsub /^ +/, ""
          There are no installed boxes! Use `vagrant box add` to add some.
        END
      }

      it { should eq Set.new }
    end
  end
end
