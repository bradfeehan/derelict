module Derelict
  class Box
    # A class that handles managing boxes for a Vagrant instance
    class Manager
      # Include "memoize" class method to memoize methods
      extend Memoist

      # Include "logger" method to get a logger for this class
      include Utils::Logger

      attr_reader :instance

      # Initializes a Manager for use with a particular instance
      #
      #   * instance: The Derelict::Instance which will have its
      #               boxes managed by this Manager
      def initialize(instance)
        @instance = instance
        logger.debug "Successfully initialized #{description}"
      end

      # Retrieves the Set of currently installed boxes
      def list
        logger.info "Retrieving Vagrant box list for #{description}"
        output = instance.execute!(:box, "list").stdout
        Derelict::Parser::BoxList.new(output).boxes
      end
      memoize :list

      # Determines whether a particular box is installed
      #
      #   * box_name: Name of the box to look for (as a string)
      def present?(box_name, provider)
        fetch(box_name, provider)
        true
      rescue Box::NotFound
        false
      end

      # Adds a box from a file or URL
      #
      # The provider will be automatically determined from the box
      # file's manifest.
      #
      #   * box_name: The name of the box to add (e.g. "precise64")
      #   * source:   The URL or path to the box file
      #   * options:  Hash of options. Valid keys:
      #      * log:   Whether to log the output (optional, defaults to
      #               false)
      def add(box_name, source, options = {})
        options = {:log => false}.merge(options)
        logger.info <<-END.gsub(/ {10}|\n\Z/, '')
          Adding box '#{box_name}' from '#{source}' using #{description}
        END

        command = [:box, "add", box_name, source]
        command << "--force" if options[:force]

        log_block = options[:log] ? shell_log_block : nil
        instance.execute!(*command, &log_block).tap do
          flush_cache # flush memoized method return values
        end
      end

      # Removes an installed box for a particular provider
      #
      #   * box_name:    Name of the box to remove (e.g. "precise64")
      #   * options:     Hash of options. Valid keys:
      #      * log:      Whether to log the output (optional, defaults
      #                  to false)
      #      * provider: If specified, only the box for a particular
      #                  provider is removed; otherwise (by default),
      #                  the box is removed for all providers
      def remove(box_name, options = {})
        options = {:log => false, :provider => nil}.merge(options)

        provider = options[:provider]
        command = [:box, "remove", box_name]
        command << provider unless provider.nil?

        logger.info <<-END.gsub(/ {10}|\n\Z/, '')
          Removing box '#{box_name}' for '#{provider}' using #{description}
        END

        log_block = options[:log] ? shell_log_block : nil
        instance.execute!(*command, &log_block).tap do
          flush_cache # flush memoized method return values
        end
      end

      # Retrieves a box with a particular name
      #
      #   * box_name: Name of the box to look for (as a string)
      def fetch(box_name, provider)
        box = list.find do |box|
          box.name == box_name && box.provider == provider
        end

        raise Box::NotFound.new box_name, provider if box.nil?
        box
      end

      # Provides a description of this Connection
      #
      # Mainly used for log messages.
      def description
        "Derelict::Box::Manager for #{instance.description}"
      end
    end
  end
end
