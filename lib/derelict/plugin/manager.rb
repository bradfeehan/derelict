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
        logger.info "Retrieving Vagrant plugin list for #{description}"
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

      # Installs a plugin (optionally a particular version)
      #
      # If no version is specified, the latest stable version is used
      # by Vagrant.
      #
      #   * plugin_name: Name of the plugin to install (as a string)
      #   * version:     Particular version to install (optional,
      #                  latest version will be installed if omitted)
      def install(plugin_name, version = nil)
        logger.info "Installing plugin '#{plugin_name}' using #{description}"
        command = [:plugin, "install", plugin_name]
        command.concat ["--plugin-version", version] unless version.nil?
        instance.execute! *command
      end

      # Uninstalls a particular Vagrant plugin
      #
      #   * plugin_name: Name of the plugin to uninstall (as a string)
      def uninstall(plugin_name)
        logger.info "Uninstalling plugin '#{plugin_name}' using #{description}"
        instance.execute! :plugin, "uninstall", plugin_name
      end

      # Updates a particular Vagrant plugin
      #
      #   * plugin_name: Name of the plugin to update (as a string)
      def update(plugin_name)
        logger.info "Updating plugin '#{plugin_name}' using #{description}"
        instance.execute! :plugin, "update", plugin_name
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
