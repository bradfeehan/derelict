require "derelict"

describe Derelict::Connection::NotFound do
  subject { Derelict::Connection::NotFound.new "/foo/bar" }

  it "is autoloaded" do
    should be_a Derelict::Connection::NotFound
  end

  its(:message) {
    should eq "Invalid Derelict connection: Vagrantfile not found for /foo/bar"
  }
end
