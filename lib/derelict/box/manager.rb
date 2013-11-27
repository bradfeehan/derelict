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
