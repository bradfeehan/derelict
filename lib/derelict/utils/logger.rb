module Derelict
  module Utils
    # Provides a method to retrieve a logger
    module Logger
      autoload :ArrayOutputter, "derelict/utils/logger/array_outputter"
      autoload :InvalidType,    "derelict/utils/logger/invalid_type"
      autoload :RawFormatter,   "derelict/utils/logger/raw_formatter"

      # Retrieves the logger for this class
      def logger(options = {})
        options = {:type => :internal}.merge(options)

        case options[:type].to_sym
          when :external
            external_logger
          when :internal
            find_or_create_logger(logger_name)
          else raise InvalidType.new options[:type]
        end
      end

      private
        # A block that can be passed to #execute to log the output
        def shell_log_block
          Proc.new do |stdout, stderr|
            # Only stdout or stderr is populated, the other will be nil
            logger(:type => :external).info(stdout || stderr)
          end
        end

        # Finds or creates a Logger with a particular fullname
        def find_or_create_logger(fullname)
          Log4r::Logger[fullname.to_s] || Log4r::Logger.new(fullname.to_s)
        end

        # Gets the "external" logger, used to print to stdout
        def external_logger
          @@external ||= find_or_create_logger("external").tap do |external|
            logger.debug "Created external logger instance"
            external.add(Log4r::Outputter.stdout.tap do |outputter|
              outputter.formatter = RawFormatter.new
            end)
          end
        end

        # Retrieves the name of the logger for this class
        #
        # By default, the name of the logger is just the lowercase
        # version of the class name.
        def logger_name
          if self.is_a? Module
            self.name.downcase
          else
            self.class.name.downcase
          end
        end
    end
  end
end
