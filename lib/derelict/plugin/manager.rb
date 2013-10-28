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

      # Determines whether a particular plugin is installed
      #
      #   * plugin_name: Name of the plugin to look for (as a string)
      def installed?(plugin_name)
        fetch plugin_name; true
      rescue Plugin::NotFound
        false
      end

      # Retrieves a plugin with a particular name
      #
      #   * plugin_name: Name of the plugin to look for (as a string)
      def fetch(plugin_name)
        list.find {|plugin| plugin.name == plugin_name}.tap do |plugin|
          raise Plugin::NotFound.new plugin_name if plugin.nil?
        end
      end

      # Provides a description of this Connection
      #
      # Mainly used for log messages.
      def description
        "Derelict::Plugin::Manager for #{instance.description}"
      end
    end
  end
end
