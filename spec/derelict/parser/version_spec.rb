require "spec_helper"

describe Derelict::Parser::Version do
  let(:parser) { Derelict::Parser::Version.new stdout }

  describe "#version" do
    subject { parser.version }

    context "on Vagrant 1.0.7" do
      let(:stdout) { "Vagrant version 1.0.7\n" }
      it { should eq "1.0.7" }
    end

    context "on Vagrant 1.3.4" do
      let(:stdout) { "Vagrant v1.3.4\n" }
      it { should eq "1.3.4" }
    end
  end
end
