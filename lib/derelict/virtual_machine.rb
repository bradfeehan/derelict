module Derelict
  # A Vagrant virtual machine in a particular Derelict connection
  class VirtualMachine
    autoload :Invalid,  "derelict/virtual_machine/invalid"
    autoload :NotFound, "derelict/virtual_machine/not_found"

    # Include "logger" method to get a logger for this class
    include Logger

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

    # Start this Vagrant virtual machine
    #
    #   * options: Hash of options
    #     * log: Should the log output be printed? (optional, defaults
    #            to false)
    def up(options = {})
      logger.info "Bringing up #{description}"
      options = {:log => false}.merge(options)
      connection.execute! :up, name, &shell_log_block(options[:log])
    end

    # Halt this Vagrant virtual machine
    #
    #   * options: Hash of options
    #     * log: Should the log output be printed? (optional, defaults
    #            to false)
    def halt(options = {})
      logger.info "Halting #{description}"
      options = {:log => false}.merge(options)
      connection.execute! :halt, name, &shell_log_block(options[:log])
    end

    # Destroy this Vagrant virtual machine
    #
    # There is no interactive confirmation -- this method uses the
    # --force option to "vagrant destroy", so it will be destroyed
    # immediately.
    #
    # This will permanently delete the virtual machine. This generally
    # shouldn't be a big deal, as it can be re-created using "up",
    # however be aware that data is being deleted.
    #
    #   * options: Hash of options
    #     * log: Should the log output be printed? (optional, defaults
    #            to false)
    def destroy(options = {})
      logger.info "Destroying #{description}"
      options = {:log => false}.merge(options)
      connection.execute! :destroy, name, '--force', &shell_log_block(options[:log])
    end

    # Reload this Vagrant virtual machine
    #
    # Reloading involves a "halt" (shut down) followed by "up" (boot).
    #
    #   * options: Hash of options
    #     * log: Should the log output be printed? (optional, defaults
    #            to false)
    def reload(options = {})
      logger.info "Reloading #{description}"
      options = {:log => false}.merge(options)
      connection.execute! :reload, name, &shell_log_block(options[:log])
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
  end
end
