module Derelict
  # Parses the output of "vagrant --version"
  class Parser::Version < Parser
    autoload :InvalidFormat, "derelict/parser/version/invalid_format"

    # Regexp to extract the version from the "vagrant --version" output
    PARSE_VERSION_FROM_OUTPUT = /^Vagrant v(?:ersion )?(.*)?$/

    # Determines the version of Vagrant based on the output
    def version
      @version ||= (
        matches = output.match PARSE_VERSION_FROM_OUTPUT
        raise InvalidFormat.new output if matches.nil?
        matches.captures[0]
      )
    end
  end
end
