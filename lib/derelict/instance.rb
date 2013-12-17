module Derelict
  # Represents a Vagrant instance installed via the Installer package
  class Instance
    autoload :CommandFailed, "derelict/instance/command_failed"
    autoload :Invalid,       "derelict/instance/invalid"
    autoload :MissingBinary, "derelict/instance/missing_binary"
    autoload :NonDirectory,  "derelict/instance/non_directory"
    autoload :NotFound,      "derelict/instance/not_found"

    # Include "memoize" class method to memoize methods
    extend Memoist

    # Include "logger" method to get a logger for this class
    include Utils::Logger

    # The default path to the Vagrant installation folder
    DEFAULT_PATH = "/Applications/Vagrant"

    attr_reader :path

    # Initialize an instance for a particular directory
    #
    #   * path: The path to the Vagrant installation folder (optional,
    #           defaults to DEFAULT_PATH)
    def initialize(path = DEFAULT_PATH)
      @path = path
      logger.debug "Successfully initialized #{description}"
    end

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
      logger.debug "Starting validation for #{description}"
      raise NotFound.new path unless File.exists? path
      raise NonDirectory.new path unless File.directory? path
      raise MissingBinary.new vagrant unless File.exists? vagrant
      raise MissingBinary.new vagrant unless File.executable? vagrant
      logger.info "Successfully validated #{description}"
      self
    end

    # Determines the version of this Vagrant instance
    def version
      logger.info "Determining Vagrant version for #{description}"
      output = execute!("--version").stdout
      Derelict::Parser::Version.new(output).version
    end
    memoize :version

    # Executes a Vagrant subcommand using this instance
    #
    #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
    #   * arguments:  Arguments to pass to the subcommand (optional)
    #   * options:    If the last argument is a Hash, it will be used
    #                 as a hash of options. A list of valid options is
    #                 below. Any options provided that aren't in the
    #                 list of valid options will get passed through to
    #                 Shell.execute (from the "shell-executer" gem).
    #                 Valid option keys:
    #      * sudo:    Whether to run the command as root, or not
    #                 (defaults to false)
    #   * block:      Passed through to Shell.execute (shell-executer)
    def execute(subcommand, *arguments, &block)
      options = arguments.last.is_a?(Hash) ? arguments.pop : Hash.new
      command = command(subcommand, *arguments)
      command = "sudo -- #{command}" if options.delete(:sudo)
      logger.debug "Executing #{command} using #{description}"
      Executer.execute command, options, &block
    end

    # Executes a Vagrant subcommand, raising an exception on failure
    #
    #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
    #   * arguments:  Arguments to pass to the subcommand (optional)
    #   * block:      Passed through to Shell.execute (shell-executer)
    #
    # Raises +Derelict::Instance::CommandFailed+ if the command fails.
    def execute!(subcommand, *arguments, &block)
      execute(subcommand, *arguments, &block).tap do |result|
        unless result.success?
          command = command(subcommand, *arguments)
          exception = CommandFailed.new command, result
          logger.warn "Command #{command} failed: #{exception.message}"
          raise exception
        end
      end
    end

    # Initializes a Connection for use in a particular directory
    #
    #   * instance: The Derelict::Instance to use to control Vagrant
    #   * path:     The project path, which contains the Vagrantfile
    def connect(path)
      logger.info "Creating connection for '#{path}' by #{description}"
      Derelict::Connection.new(self, path).validate!
    end

    # Initializes a plugin manager for use with this instance
    def plugins
      logger.info "Creating plugin manager for #{description}"
      Derelict::Plugin::Manager.new(self)
    end

    # Initializes a box manager for use with this instance
    def boxes
      logger.info "Creating box manager for #{description}"
      Derelict::Box::Manager.new(self)
    end

    # Provides a description of this Instance
    #
    # Mainly used for log messages.
    def description
      "Derelict::Instance at '#{path}'"
    end

    private
      # Retrieves the path to the vagrant binary for this instance
      def vagrant
        File.join(@path, "bin", "vagrant").tap do |vagrant|
          logger.debug "Vagrant binary for #{description} is '#{vagrant}'"
        end
      end
      memoize :vagrant


      # Constructs the command to execute a Vagrant subcommand
      #
      #   * subcommand: Vagrant subcommand to run (:up, :status, etc.)
      #   * arguments:  Arguments to pass to the subcommand (optional)
      def command(subcommand, *arguments)
        args = [vagrant, subcommand.to_s, arguments].flatten
        args.map {|a| Shellwords.escape a }.join(' ').tap do |command|
          logger.debug "Generated command '#{command}' from " +
            "subcommand '#{subcommand.to_s}' with arguments " +
            arguments.inspect
        end
      end
  end
end
