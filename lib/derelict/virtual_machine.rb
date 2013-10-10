module Derelict
  # A Vagrant virtual machine in a particular Derelict connection
  class VirtualMachine
    autoload :Invalid,  "derelict/virtual_machine/invalid"
    autoload :NotFound, "derelict/virtual_machine/not_found"

    attr_reader :connection
    attr_reader :name

    # Initializes a new VirtualMachine for a connection and name
    #
    #   * connection: The +Derelict::Connection+ to use to manipulate
    #                 the VirtualMachine instance
    #   * name:       The name of the virtual machine, used when
    #                 communicating with the connection (optional, if
    #                 omitted, the primary VM will be used)
    def initialize(connection, name = nil)
      @connection = connection
      @name = name
    end

    # Validates the data used for this connection
    #
    # Raises exceptions on failure:
    #
    #   * +Derelict::VirtualMachine::NotFound+ if the connection
    #     doesn't know about a virtual machine with the requested
    #     name
    def validate!
      raise NotFound.new connection, name unless exists?
      self
    end

    # Determines whether this Vagrant virtual machine exists
    #
    # Returns +true+ if the connection reports a virtual machine with
    # the requested name, otherwise returns +false+.
    def exists?
      @exists ||= status.exists? name
    end

    # Retrieves the (parsed) status from the connection
    def status
      @status ||= (
        output = connection.execute!(:status).stdout
        Derelict::Parser::Status.new(output)
      )
    end
  end
end
