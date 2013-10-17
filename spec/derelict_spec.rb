require "spec_helper"

describe Derelict do
  let(:logger) { Derelict.logger }

  describe "::logger" do
    subject { logger }
    it { should be_a Log4r::Logger }
    its(:name) { should eq "derelict" }
  end
end
