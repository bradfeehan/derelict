module Derelict
  # Represents an individual Vagrant plugin at a particular version
  class Plugin
    autoload :Manager,  "derelict/plugin/manager"
    autoload :NotFound, "derelict/plugin/not_found"

    attr_reader :name, :version

    # Initializes a plugin with a particular name and version
    #
    #   * name:    The name of the plugin represented by this object
    #   * version: The version of the plugin represented by this object
    def initialize(name, version)
      @name = name
      @version = version
    end

    # Ensure equivalent Plugins are equal to this one
    def ==(other)
      other.name == name and other.version == version
    end
    alias_method :eql?, :==

    # Make equivalent Plugins hash to the same value
    def hash
      name.hash ^ version.hash
    end
  end
end
