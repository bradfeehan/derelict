module Derelict
  # Represents an individual Vagrant box for a particular provider
  class Box
    autoload :NotFound, "derelict/box/not_found"

    attr_reader :name, :provider

    # Initializes a box with a particular name and provider
    #
    #   * name:     The name of the box represented by this object
    #   * provider: The provider of the box represented by this object
    def initialize(name, provider)
      @name = name
      @provider = provider
    end

    # Ensure equivalent Boxes are equal to this one
    def ==(other)
      other.name == name and other.provider == provider
    end
    alias_method :eql?, :==

    # Make equivalent Boxes hash to the same value
    def hash
      name.hash ^ provider.hash
    end
  end
end
