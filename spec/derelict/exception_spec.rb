require "spec_helper"

describe Derelict::Exception do
  it "is autoloaded" do
    should be_a Derelict::Exception
  end

  it "inherits from ::Exception" do
    should be_a ::Exception
  end
end
