module Derelict
  # Represents a Vagrant instance installed via the Installer package
  class Instance
    autoload :Invalid,       "derelict/instance/invalid"
    autoload :MissingBinary, "derelict/instance/missing_binary"
    autoload :NonDirectory,  "derelict/instance/non_directory"
    autoload :NotFound,      "derelict/instance/not_found"

    # The default path to the Vagrant installation folder
    DEFAULT_PATH = "/Applications/Vagrant"

    attr_reader :path

    # Initialize an instance for a particular directory
    #
    #   * path: The path to the Vagrant installation folder (optional,
    #           defaults to DEFAULT_PATH)
    def initialize(path = DEFAULT_PATH)
      @path = path
      validate!
    end

    # Executes a Vagrant subcommand using this instance
    #
    #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
    #   * arguments:  Arguments to pass to the subcommand (optional)
    #   * block:      Passed through to Shell.execute (shell-executer)
    def execute(subcommand, *arguments, &block)
      Shell.execute(command(subcommand, *arguments), &block)
    end

    # Initializes a Connection for use in a particular directory
    #
    #   * instance: The Derelict::Instance to use to control Vagrant
    #   * path:     The project path, which contains the Vagrantfile
    def connect(path)
      Derelict::Connection.new self, path
    end

    private
      # Validates the data used for this instance
      #
      # Raises exceptions on failure:
      #
      #   * +Derelict::Instance::NotFound+ if the instance is not found
      #   * +Derelict::Instance::NonDirectory+ if the path is a file,
      #     instead of a directory as expected
      #   * +Derelict::Instance::MissingBinary+ if the "vagrant" binary
      #     isn't in the expected location or is not executable
      def validate!
        raise NotFound.new path unless File.exists? path
        raise NonDirectory.new path unless File.directory? path
        raise MissingBinary.new vagrant unless File.exists? vagrant
        raise MissingBinary.new vagrant unless File.executable? vagrant
      end

      # Retrieves the path to the vagrant binary for this instance
      def vagrant
        File.join @path, "bin", "vagrant"
      end

      # Constructs the command to execute a Vagrant subcommand
      #
      #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
      #   * arguments:  Arguments to pass to the subcommand (optional)
      def command(subcommand, *arguments)
        arguments = [vagrant, subcommand.to_s, arguments].flatten
        arguments.map {|arg| Shellwords.escape arg }.join(' ')
      end
  end
end
