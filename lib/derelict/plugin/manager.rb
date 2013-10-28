module Derelict
  class Plugin
    # A class that handles managing plugins for a Vagrant instance
    class Manager
      # Include "memoize" class method to memoize methods
      extend Memoist

      # Include "logger" method to get a logger for this class
      include Utils::Logger

      attr_reader :instance

      # Initializes a Manager for use with a particular instance
      #
      #   * instance: The Derelict::Instance which will have its
      #               plugins managed by this Manager
      def initialize(instance)
        @instance = instance
        logger.debug "Successfully initialized #{description}"
      end

      # Retrieves the Set of currently installed plugins
      def list
        output = instance.execute!(:plugin, "list").stdout
        Derelict::Parser::PluginList.new(output).plugins
      end
      memoize :list

      # Provides a description of this Connection
      #
      # Mainly used for log messages.
      def description
        "Derelict::Plugin::Manager for #{instance.description}"
      end
    end
  end
end
