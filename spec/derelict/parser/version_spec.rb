require "spec_helper"

describe Derelict::Parser::Version do
  let(:parser) { Derelict::Parser::Version.new stdout }

  describe "#version" do
    subject { parser.version }

    context "with 'Vagrant version 1.0.7'" do
      let(:stdout) { "Vagrant version 1.0.7\n" }
      it { should eq "1.0.7" }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG version: Successfully initialized Derelict::Parser::Version instance\n",
        "DEBUG version: Parsing version from output using Derelict::Parser::Version instance\n",
      ]}
    end

    context "with 'Vagrant v1.3.4'" do
      let(:stdout) { "Vagrant v1.3.4\n" }
      it { should eq "1.3.4" }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG version: Successfully initialized Derelict::Parser::Version instance\n",
        "DEBUG version: Parsing version from output using Derelict::Parser::Version instance\n",
      ]}
    end

    context "with 'Vagrant 1.3.3'" do
      let(:stdout) { "Vagrant 1.3.3\n" }
      it { should eq "1.3.3" }

      include_context "logged messages"
      let(:expected_logs) {[
        "DEBUG version: Successfully initialized Derelict::Parser::Version instance\n",
        "DEBUG version: Parsing version from output using Derelict::Parser::Version instance\n",
      ]}
    end
  end
end
