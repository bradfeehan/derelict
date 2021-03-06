require "derelict/version"
require "log4r"
require "memoist"
require "open4"
require "set"
require "shellwords"

Log4r::Logger["root"] # creates the level constants (INFO, etc).

# Main module/entry point for Derelict
module Derelict
  autoload :Box,            "derelict/box"
  autoload :Connection,     "derelict/connection"
  autoload :Exception,      "derelict/exception"
  autoload :Executer,       "derelict/executer"
  autoload :Instance,       "derelict/instance"
  autoload :Parser,         "derelict/parser"
  autoload :Plugin,         "derelict/plugin"
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
    logger.level = options[:enabled] ? options[:level] : Log4r::OFF

    if options[:enabled]
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
    def self.debug_options_defaults
      {
        :enabled => true,
        :level => Log4r::INFO,
      }
    end

    def self.stderr
      Log4r::Outputter.stderr
    end
end
