require "derelict/version"
require "log4r"
require "shell/executer"

module Derelict
  autoload :Connection,     "derelict/connection"
  autoload :Exception,      "derelict/exception"
  autoload :Instance,       "derelict/instance"
  autoload :Log4r,          "derelict/log4r"
  autoload :Logger,         "derelict/logger"
  autoload :Parser,         "derelict/parser"
  autoload :VirtualMachine, "derelict/virtual_machine"

  # Make functions accessible by Derelict.foo and private when included
  module_function

  # Include "logger" method to get a logger for this class
  extend Logger

  # Creates a new Derelict instance for a Vagrant installation
  #
  #   * path: The path to the Vagrant installation (optional, defaults
  #           to Instance::DEFAULT_PATH)
  def instance(path = Instance::DEFAULT_PATH)
    Instance.new(path).validate!
  end

  # Enables (or disables) Derelict's debug mode
  #
  # When in debug mode, Derelict will log to stderr. The debug level
  # can be controlled as well (which affects the verbosity of the
  # logging).
  def debug!(options = {})
    ::Log4r::Logger["root"] # creates the level constants (INFO, etc).

    options = {
      :enabled => true,
      :level => ::Log4r::INFO,
    }.merge options

    if options[:enabled]
      stderr = ::Log4r::Outputter.stderr
      logger.add stderr unless logger.outputters.include? stderr
      logger.level = options[:level]
      logger.info "enabling debug mode"
    else
      logger.info "disabling debug mode"
      logger.remove "stderr"
      logger.level = ::Log4r::OFF
    end

    self
  end
end
