module Derelict
  # A Vagrant virtual machine in a particular Derelict connection
  class VirtualMachine
    autoload :Invalid,  "derelict/virtual_machine/invalid"
    autoload :NotFound, "derelict/virtual_machine/not_found"

    # Include "memoize" class method to memoize methods
    extend Memoist

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
    end

    # Determines whether this Vagrant virtual machine exists
    #
    # Returns +true+ if the connection reports a virtual machine with
    # the requested name, otherwise returns +false+.
    def exists?
      status.exists? name
    end
    memoize :exists?

    # Gets the current state of this Vagrant virtual machine
    #
    # The state is returned as a symbol, e.g. :running.
    def state
      status.state name
    end
    memoize :state

    # Determines whether this virtual machine is currently running
    def running?
      (state == :running)
    end
    memoize :running?

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
      define_method :"#{command}!" do |*opts|
        # Ideally this block would have one argument with a default
        # value of an empty Hash. Unfortunately, setting a default
        # value for the arguments to a block is only supported in Ruby
        # 1.9+. The splatted arguments thing is a way to allow zero or
        # one argument, but it actually allows any number of arguments.
        # So we need to emulate the error Ruby would throw if you give
        # the wrong number of arguments.
        if opts.length > 1
          message = "wrong number of arguments (#{opts.length} for 0-1)"
          raise ArgumentError.new message
        end

        # Set defaults for the opts hash
        opts = {:color => false, :log => false}.merge(opts.first || {})

        # Log message if there's one for this command
        log_message_for(command).tap {|m| logger.info m unless m.nil? }

        # Execute the command!
        execute! command, opts
      end
    end

    # Retrieves the (parsed) status from the connection
    def status
      logger.info "Retrieving Vagrant status for #{description}"
      output = connection.execute!(:status).stdout
      Derelict::Parser::Status.new(output)
    end
    memoize :status

    # Provides a description of this Connection
    #
    # Mainly used for log messages.
    def description
      "Derelict::VirtualMachine '#{name}' from #{connection.description}"
    end

    private
      # Executes a command on the connection for this VM
      #
      #   * command: The command to execute (as a symbol)
      #   * options: A Hash of options, with the following optional keys:
      #       * log:      Logs the output of the command if true
      #                   (defaults to false)
      #       * color:    Uses color in the log output (defaults to
      #                   false, only relevant if log is true)
      #       * provider: The Vagrant provider to use, one of
      #                   "virtualbox" or "vmware_fusion" (defaults to
      #                   "virtualbox")
      def execute!(command, options)
        # Build up the arguments to pass to connection.execute!
        arguments = [command, name, *arguments_for(command)]
        arguments << "--color" if options[:color]
        if options[:provider]
          arguments << "--provider"
          arguments << options[:provider]
        end

        # Set up the block to use when executing -- if logging is
        # enabled, use a block that logs the output; otherwise no block.
        block = options[:log] ? shell_log_block : nil

        # Execute the command
        connection.execute! *arguments, &block
      end

      # A block that can be passed to #execute to log the output
      def shell_log_block
        Proc.new do |stdout, stderr|
          # Only stdout or stderr is populated, the other will be nil
          logger(:type => :external).info(stdout || stderr)
        end
      end
      memoize :shell_log_block

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
