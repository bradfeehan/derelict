require "spec_helper"

describe Derelict::Parser::PluginList do
  subject { Derelict::Parser::PluginList.new output }
  let(:output) { nil }

  it "is autoloaded" do
    should be_a Derelict::Parser::PluginList
  end

  context "with valid output" do
    let(:output) {
      <<-END.gsub /^ +/, ""
        foo (2.3.4)
        bar (1.2.3)
      END
    }

    describe "#plugins" do
      subject { Derelict::Parser::PluginList.new(output).plugins }
      let(:foo) { Derelict::Plugin.new "foo", "2.3.4" }
      let(:bar) { Derelict::Plugin.new "bar", "1.2.3" }
      it { should eq Set[foo, bar] }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG pluginlist: Successfully initialized Derelict::Parser::PluginList instance\n",
      ]}
    end
  end
end
