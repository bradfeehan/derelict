require "spec_helper"

describe Derelict::Exception::OptionalReason do
  context "with #default_message left unimplemented" do
    let(:exception) do
      Class.new ::Exception do
        include Derelict::Exception::OptionalReason
      end
    end

    describe "#initialize" do
      subject { exception.new reason }
      let(:reason) { "test reason" }

      it "should raise NotImplementedError" do
        expect { subject }.to raise_error NotImplementedError
      end
    end
  end

  context "with #default_message implemented" do
    let(:exception) do
      Class.new ::Exception do
        include Derelict::Exception::OptionalReason
        private
          def default_message
            "test"
          end
      end
    end

    describe "#initialize" do
      subject { exception.new reason }
      let(:reason) { "test reason" }

      it "should raise NotImplementedError" do
        expect { subject }.to_not raise_error
      end
    end
  end
end
