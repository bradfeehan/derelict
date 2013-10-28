module Derelict
  # Represents an individual Vagrant plugin at a particular version
  class Plugin
    attr_reader :name, :version

    # Initializes a plugin with a particular name and version
    #
    #   * name:    The name of the plugin represented by this object
    #   * version: The version of the plugin represented by this object
    def initialize(name, version)
      @name = name
      @version = version
    end
  end
end
