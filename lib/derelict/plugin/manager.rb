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
      def installed?(plugin_name, version = nil)
        fetch(plugin_name).version == version or version.nil?
      rescue Plugin::NotFound
        false
      end

      # Installs a plugin (optionally a particular version)
      #
      # If no version is specified, the latest stable version is used
      # by Vagrant.
      #
      #   * plugin_name: Name of the plugin to install (as a string)
      #   * options:     Hash of options, valid keys:
      #      * version:  Particular version to install (optional,
      #                  latest version will be installed if omitted)
      #      * log:      Whether to log the output (optional, defaults
      #                  to false)
      def install(plugin_name, options = {})
        options = {:log => false, :version => nil}.merge(options)
        logger.info "Installing plugin '#{plugin_name}' using #{description}"

        version = options[:version]
        command = [:plugin, "install", plugin_name]
        command.concat ["--plugin-version", version] unless version.nil?

        log_block = options[:log] ? shell_log_block : nil
        instance.execute!(*command, &log_block).tap do
          flush_cache # flush memoized method return values
        end
      end

      # Uninstalls a particular Vagrant plugin
      #
      #   * plugin_name: Name of the plugin to uninstall (as a string)
      def uninstall(plugin_name, options = {})
        options = {:log => false}.merge(options)
        logger.info "Uninstalling plugin '#{plugin_name}' using #{description}"

        log_block = options[:log] ? shell_log_block : nil
        instance.execute!(:plugin, "uninstall", plugin_name, &log_block).tap do
          flush_cache # flush memoized method return values
        end
      end

      # Updates a particular Vagrant plugin
      #
      #   * plugin_name: Name of the plugin to update (as a string)
      def update(plugin_name, options = {})
        options = {:log => false}.merge(options)
        logger.info "Updating plugin '#{plugin_name}' using #{description}"

        log_block = options[:log] ? shell_log_block : nil
        instance.execute!(:plugin, "update", plugin_name, &log_block).tap do
          flush_cache # flush memoized method return values
        end
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
