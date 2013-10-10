module Derelict
  # Connects a Derelict::Instance to its use in a particular directory
  class Connection
    autoload :Invalid,  "derelict/connection/invalid"
    autoload :NotFound, "derelict/connection/not_found"

    attr_reader :instance
    attr_reader :path

    # Initializes a Connection for use in a particular directory
    #
    #   * instance: The Derelict::Instance to use to control Vagrant
    #   * path:     The project path, which contains the Vagrantfile
    def initialize(instance, path)
      @instance = instance
      @path = path
    end

    # Executes a Vagrant subcommand using this connection
    #
    #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
    #   * arguments:  Arguments to pass to the subcommand (optional)
    #   * block:      Passed through to @instance#execute
    def execute(subcommand, *arguments, &block)
      Dir.chdir path do
        instance.execute subcommand.to_sym, *arguments, &block
      end
    end

    # Executes a Vagrant subcommand, raising an exception on failure
    #
    #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
    #   * arguments:  Arguments to pass to the subcommand (optional)
    #   * block:      Passed through to Shell.execute (shell-executer)
    #
    # Raises +Derelict::Instance::CommandFailed+ if the command fails.
    def execute!(subcommand, *arguments, &block)
      Dir.chdir path do
        instance.execute! subcommand.to_sym, *arguments, &block
      end
    end

    # Retrieves a Derelict::VirtualMachine for a particular VM
    #
    #   * name: The name of the virtual machine to retrieve
    def vm(name)
      Derelict::VirtualMachine.new self, name
    end

    private
      # Validates the data used for this connection
      #
      # Raises exceptions on failure:
      #
      #   * +Derelict::Connection::NotFound+ if the path is not found
      def validate!
        raise NotFound.new path unless File.exists? path
      end
  end
end
