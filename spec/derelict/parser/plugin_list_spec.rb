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

  context "with plugins needing re-install" do
    let(:output) {
      <<-END.gsub /^ {8}/, ""
        The following plugins were installed with a version of Vagrant
        that had different versions of underlying components. Because
        these component versions were changed (which rarely happens),
        the plugins must be uninstalled and reinstalled.

        To ensure that all the dependencies are properly updated as well
        it is _highly recommended_ to do a `vagrant plugin uninstall`
        prior to reinstalling.

        This message will not go away until all the plugins below are
        either uninstalled or uninstalled then reinstalled.

        The plugins below will not be loaded until they're uninstalled
        and reinstalled:

        foo, bar
        foo (2.3.4)
        bar (1.2.3)
      END
    }

    describe "#plugins" do
      subject { Derelict::Parser::PluginList.new(output).plugins }

      it "should raise NeedsReinstall" do
        expect { subject }.to raise_error(Derelict::Parser::PluginList::NeedsReinstall)
      end

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG pluginlist: Successfully initialized Derelict::Parser::PluginList instance\n",
      ]}
    end
  end
end
