require "derelict/version"
require "shell/executer"

module Derelict
  autoload :Connection,     "derelict/connection"
  autoload :Exception,      "derelict/exception"
  autoload :Instance,       "derelict/instance"
  autoload :Parser,         "derelict/parser"
  autoload :VirtualMachine, "derelict/virtual_machine"

  # Make functions accessible by Derelict.foo and private when included
  module_function

  # Creates a new Derelict instance for a Vagrant installation
  #
  #   * path: The path to the Vagrant installation (optional, defaults
  #           to Instance::DEFAULT_PATH)
  def instance(path = Instance::DEFAULT_PATH)
    Instance.new(path).validate!
  end
end
