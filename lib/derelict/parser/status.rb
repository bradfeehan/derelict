module Derelict
  # Parses the output of "vagrant status"
  class Parser::Status < Parser
    autoload :InvalidFormat, "derelict/parser/status/invalid_format"

    # Regexp to extract the VM list from the "vagrant status" output
    PARSE_LIST_FROM_OUTPUT = /\n\n((?:.*\n)+)\n/

    # Regexp to extract the state from a line in the VM list
    PARSE_STATE_FROM_LIST_ITEM = %r[
      ^(.*?) # VM name starts at the start of the line,
      \s{2,} # to the first instance of 2 or more spaces.
      (.*?)  # VM state starts after the whitespace,
      \s+\(  # continuing until whitespace and open bracket.
        (.*) # The provider name starts after the bracket,
      \)$    # and ends at a closing bracket at line end.
      ]x     # Ignore whitespace to allow these comments

    # Retrieves the names of all virtual machines in the output
    #
    # The names are returned as an array of symbols.
    def vm_names
      states.keys
    end

    # Determines if a particular virtual machine exists in the output
    #
    #   * vm_name: The name of the virtual machine to look for
    def exists?(vm_name)
      vm_names.include? vm_name.to_sym
    end

    # Determines the state of a particular virtual machine
    #
    # The state is returned as a symbol, e.g. :running.
    #
    #   * vm_name: The name of the virtual machine to retrieve state
    def state(vm_name)
      unless states.include? vm_name.to_sym
        raise Derelict::VirtualMachine::NotFound.new vm_name
      end

      states[vm_name.to_sym]
    end

    # Provides a description of this Parser
    #
    # Mainly used for log messages.
    def description
      "Derelict::Parser::Status instance"
    end

    private
      # Retrieves the virtual machine list section of the output
      def vm_lines
        @vm_lines ||= output.match(PARSE_LIST_FROM_OUTPUT).tap {|list|
          logger.debug "Parsing VM list from output using #{description}"
          raise InvalidFormat.new "Couldn't find list of VMs" if list.nil?
        }.captures[0].lines
      rescue Derelict::Parser::Status::InvalidFormat => e
        logger.warn "List parsing failed for #{description}: #{e.message}"
        raise
      end

      # Retrieves the state data for all virtual machines in the output
      #
      # The state is returned as a Hash, mapping virtual machine names
      # (as symbols) to their state (also as a symbol). Both of these
      # symbols have spaces converted to underscores (for convenience
      # when writing literals in other code).
      def states
        @states ||= (
          logger.debug "Parsing states from VM list using #{description}"
          data = vm_lines.map {|l| l.match PARSE_STATE_FROM_LIST_ITEM }
          message = "Couldn't parse VM list"
          raise InvalidFormat.new message if data.any?(&:nil?)
          Hash[data.map {|line| [
            line.captures[0].gsub(/\s+/, "_").downcase.to_sym,
            line.captures[1].gsub(/\s+/, "_").downcase.to_sym,
          ] }]
        )
      rescue Derelict::Parser::Status::InvalidFormat => e
        logger.warn "State parsing failed for #{description}: #{e.message}"
        raise
      end
  end
end
