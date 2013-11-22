module Derelict
  # Parses the output of "vagrant status"
  class Parser::Status < Parser
    autoload :InvalidFormat, "derelict/parser/status/invalid_format"

    # Include "memoize" class method to memoize methods
    extend Memoist

    # Regexp to extract the VM list from the "vagrant status" output
    PARSE_LIST_FROM_OUTPUT = /Current machine states:\n\n((?:.*\n)+)\n/i

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
    # The names are returned as a Set of symbols.
    def vm_names
      Set[*states.keys]
    end

    # Determines if a particular virtual machine exists in the output
    #
    #   * vm_name: The name of the virtual machine to look for
    def exists?(vm_name = nil)
      return (vm_names.count > 0) if vm_name.nil?
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
        output.match(PARSE_LIST_FROM_OUTPUT).tap {|list|
          logger.debug "Parsing VM list from output using #{description}"
          raise InvalidFormat.new "Couldn't find VM list" if list.nil?
        }.captures[0].lines
      end
      memoize :vm_lines

      # Retrieves the state data for all virtual machines in the output
      #
      # The state is returned as a Hash, mapping virtual machine names
      # (as symbols) to their state (also as a symbol). Both of these
      # symbols have spaces converted to underscores (for convenience
      # when writing literals in other code).
      def states
        logger.debug "Parsing states from VM list using #{description}"
        vm_lines.inject Hash.new do |hash, line|
          hash.merge! parse_line(line.match PARSE_STATE_FROM_LIST_ITEM)
        end
      end
      memoize :states

      def parse_line(match)
        raise InvalidFormat.new "Couldn't parse VM list" if match.nil?
        Hash[*match.captures[0..1].map {|value| sanitize value }]
      end

      def sanitize(value)
        value.to_s.gsub(/\s+/, "_").downcase.to_sym
      end
  end
end
