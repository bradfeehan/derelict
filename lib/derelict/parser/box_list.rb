module Derelict
  # Parses the output of "vagrant box list"
  class Parser::BoxList < Parser
    autoload :InvalidFormat, "derelict/parser/box_list/invalid_format"

    # Include "memoize" class method to memoize methods
    extend Memoist

    # Output from "vagrant box list" if there are no boxes installed
    NO_BOXES = <<-END.gsub(/^ {6}/, '')
      There are no installed boxes! Use `vagrant box add` to add some.
    END

    # Regexp to parse a box line into a box name and provider
    #
    # Capture groups:
    #
    #   1. Box name, as listed in the output
    #   2. Name of the provider for that box
    PARSE_BOX = %r[
      ^(.*?)   # Box name starts at the start of the line
      \ +\(    # Provider is separated by spaces and open-parenthesis
        (\w+)  # Provider name
      \)$      # Ends with close-parenthesis and end-of-line
    ]x         # Ignore whitespace to allow these comments

    # Retrieves a Set containing all the boxes from the output
    def boxes
      box_lines.map {|l| parse_line l.match(PARSE_BOX) }.to_set
    end

    # Provides a description of this Parser
    #
    # Mainly used for log messages.
    def description
      "Derelict::Parser::BoxList instance"
    end

    private
      # Retrieves an array of the box lines in the output
      def box_lines
        return [] if output.match NO_BOXES
        output.lines
      end

      # Parses a single line of the output into a Box object
      def parse_line(match)
        raise InvalidFormat.new "Couldn't parse box list" if match.nil?
        Derelict::Box.new *match.captures[0..1]
      end
  end
end
