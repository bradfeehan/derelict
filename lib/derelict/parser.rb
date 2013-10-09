module Derelict
  # Base class for parsers, which extract data from command output
  class Parser
    autoload :Status, "derelict/parser/status"

    attr_reader :output

    # Initializes the parser with the output it will be parsing
    def initialize(output)
      @output = output
    end
  end
end
