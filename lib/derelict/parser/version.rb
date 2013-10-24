module Derelict
  # Parses the output of "vagrant --version"
  class Parser::Version < Parser
    autoload :InvalidFormat, "derelict/parser/version/invalid_format"

    # Include "memoize" class method to memoize methods
    extend Memoist

    # Regexp to extract the version from the "vagrant --version" output
    PARSE_VERSION_FROM_OUTPUT = /^Vagrant (?:v(?:ersion )?)?(.*)?$/

    # Determines the version of Vagrant based on the output
    def version
      logger.debug "Parsing version from output using #{description}"
      matches = output.match PARSE_VERSION_FROM_OUTPUT
      raise InvalidFormat.new output if matches.nil?
      matches.captures[0]
    end
    memoize :version

    # Provides a description of this Parser
    #
    # Mainly used for log messages.
    def description
      "Derelict::Parser::Version instance"
    end
  end
end
