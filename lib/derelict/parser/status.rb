module Derelict
  # Parses the output of "vagrant status"
  class Parser::Status < Parser
    autoload :InvalidFormat, "derelict/parser/status/invalid_format"

    # Regexp to extract the VM list from the "vagrant status" output
    PARSE_LIST_FROM_OUTPUT = /\n\n((?:.*\n)+)\n/

    # Regexp to extract the state from a line in the VM list
    PARSE_STATE_FROM_LIST_ITEM = /
      ^(?<name>.*?)     # VM name starts at the start of the line,
      \s{2,}            # to the first instance of 2 or more spaces.
      (?<state>.*?)     # VM state starts after the whitespace,
      \s+\(             # continuing until whitespace and open bracket.
        (?<provider>.*) # The provider name starts after the bracket,
      \)$               # and ends at a closing bracket at line end.
      /x                # Ignore whitespace to allow these comments

    # Extracts data from the output
    def parse!
      list = output.match PARSE_LIST_FROM_OUTPUT
      raise InvalidFormat.new "Couldn't find list of VMs" if list.nil?

      @vm_names = []
      list.captures[0].lines.each do |line|
        state = line.match PARSE_STATE_FROM_LIST_ITEM
        raise InvalidFormat.new "Couldn't parse VM list" if state.nil?
        @vm_names << state[:name].to_sym
      end
    end

    # Determines if a particular virtual machine exists in the output
    #
    #   * vm_name: The name of the virtual machine to look for
    def exists?(vm_name)
      @vm_names.include? vm_name.to_sym
    end
  end
end
