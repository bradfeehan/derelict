module Derelict
  # Provides a method to retrieve a logger
  module Logger
    # Retrieves the logger for this class
    def logger
      ::Log4r::Logger[logger_name] || ::Log4r::Logger.new(logger_name)
    end

    private
      # Retrieves the name of the logger for this class
      #
      # By default, the name of the logger is just the lowercase
      # version of the class name.
      def logger_name
        instance_name = self.respond_to?(:name) ? self.name : nil
        (instance_name or self.class.name).downcase
      end
  end
end
