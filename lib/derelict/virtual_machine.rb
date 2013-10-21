module Derelict
  # A Vagrant virtual machine in a particular Derelict connection
  class VirtualMachine
    autoload :Invalid,  "derelict/virtual_machine/invalid"
    autoload :NotFound, "derelict/virtual_machine/not_found"

    # Include "logger" method to get a logger for this class
    include Utils::Logger

    COMMANDS = [
      :up,
      :halt,
      :destroy,
      :reload,
      :suspend,
      :resume,
    ]

    attr_reader :connection
    attr_reader :name

    # Initializes a new VirtualMachine for a connection and name
    #
    #   * connection: The +Derelict::Connection+ to use to manipulate
    #                 the VirtualMachine instance
    #   * name:       The name of the virtual machine, used when
    #                 communicating with the connection)
    def initialize(connection, name)
      @connection = connection
      @name = name
      logger.debug "Successfully initialized #{description}"
    end

    # Validates the data used for this connection
    #
    # Raises exceptions on failure:
    #
    #   * +Derelict::VirtualMachine::NotFound+ if the connection
    #     doesn't know about a virtual machine with the requested
    #     name
    def validate!
      logger.debug "Starting validation for #{description}"
      raise NotFound.new name, connection unless exists?
      logger.info "Successfully validated #{description}"
      self
    rescue Derelict::VirtualMachine::Invalid => e
      logger.warn "Validation failed for #{description}: #{e.message}"
      raise
    end

    # Determines whether this Vagrant virtual machine exists
    #
    # Returns +true+ if the connection reports a virtual machine with
    # the requested name, otherwise returns +false+.
    def exists?
      @exists ||= status.exists? name
    end

    # Gets the current state of this Vagrant virtual machine
    #
    # The state is returned as a symbol, e.g. :running.
    def state
      @state ||= status.state name
    end

    # Determines whether this virtual machine is currently running
    def running?
      @running ||= (state == :running)
    end

    # Add methods for each command
    #
    # A method is defined for each of the symbols in COMMANDS. The
    # method name will be the symbol with an added bang (!). For
    # example, #up!, #halt!, etc.
    #
    # Each method takes an options hash as an argument. For example:
    #
    #   vm.up! :log => true
    #
    # This example will run the "up" command with logging enabled. The
    # option keys can optionally include any of the following symbols:
    #
    #     * log: Should the log output be printed? (defaults to false)
    COMMANDS.each do |command|
      define_method "#{command}!" do |options|
        # Log message if there's one for this command
        message = log_message_for command
        logger.info message unless message.nil?

        # Set defaults for the options hash
        options = {:log => false}.merge options

        # Execute the command, optionally logging output
        arguments = arguments_for command
        log_block = shell_log_block options[:log]
        connection.execute! command, name, *arguments, &log_block
      end
    end

    # Retrieves the (parsed) status from the connection
    def status
      @status ||= (
        logger.info "Retrieving Vagrant status for #{description}"
        output = connection.execute!(:status).stdout
        Derelict::Parser::Status.new(output)
      )
    end

    # Provides a description of this Connection
    #
    # Mainly used for log messages.
    def description
      "Derelict::VirtualMachine '#{name}' from #{connection.description}"
    end

    private
      # A block that can be passed to #execute to log the output
      #
      #   * log: Whether the output should be logged (if false, the
      #          resulting block will do nothing).
      def shell_log_block(log)
        return nil unless log
        @shell_log_block ||= Proc.new do |line|
          logger(:type => :external).info line
        end
      end

      # Retrieves the arguments for a particular action
      #
      #   * action: The symbol representing the action (one of :up,
      #             :halt, :destroy, :reload, :suspend, :resume)
      def arguments_for(action)
        case action
          when :destroy then ['--force']
          else []
        end
      end

      # Retrieves the correct log message for a particular action
      #
      #   * action: The symbol representing the action (one of :up,
      #             :halt, :destroy, :reload, :suspend, :resume)
      def log_message_for(action)
        case action
          when :up      then "Bringing up #{description}"
          when :halt    then "Halting #{description}"
          when :destroy then "Destroying #{description}"
          when :reload  then "Reloading #{description}"
          when :suspend then "Suspending #{description}"
          when :resume  then "Resuming #{description}"
          else nil
        end
      end
  end
end
