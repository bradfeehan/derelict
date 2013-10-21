require "derelict/version"
require "log4r"
require "shell/executer"

::Log4r::Logger["root"] # creates the level constants (INFO, etc).

module Derelict
  autoload :Connection,     "derelict/connection"
  autoload :Exception,      "derelict/exception"
  autoload :Instance,       "derelict/instance"
  autoload :Log4r,          "derelict/log4r"
  autoload :Parser,         "derelict/parser"
  autoload :Utils,          "derelict/utils"
  autoload :VirtualMachine, "derelict/virtual_machine"

  # Make functions accessible by Derelict.foo and private when included
  module_function

  # Include "logger" method to get a logger for this class
  extend Utils::Logger

  # Creates a new Derelict instance for a Vagrant installation
  #
  #   * path: The path to the Vagrant installation (optional, defaults
  #           to Instance::DEFAULT_PATH)
  def instance(path = Instance::DEFAULT_PATH)
    logger.info "Creating and validating new instance for '#{path}'"
    Instance.new(path).validate!
  end

  # Enables (or disables) Derelict's debug mode
  #
  # When in debug mode, Derelict will log to stderr. The debug level
  # can be controlled as well (which affects the verbosity of the
  # logging).
  #
  # Valid (symbol) keys for the options hash include:
  #
  #   * enabled: Whether debug mode should be enabled (defaults to true)
  #   * level:   Allows setting a custom log level (defaults to INFO)
  def debug!(options = {})
    options = debug_options_defaults.merge options

    logger.level = options[:level]

    if options[:enabled]
      stderr = ::Log4r::Outputter.stderr
      logger.add stderr unless logger.outputters.include? stderr
      logger.info "enabling debug mode"
    else
      logger.info "disabling debug mode"
      logger.remove "stderr"
    end

    self
  end

  private
    # Retrieves the default values for the options hash for #debug!
    def debug_options_defaults
      {
        :enabled => true,
        :level => options[:enabled] ? ::Log4r::INFO : ::Log4r::OFF,
      }
    end
end
