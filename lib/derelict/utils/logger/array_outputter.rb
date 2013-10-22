module Derelict
  module Utils
    module Logger
      # A Log4r Outputter which stores all logs in an array
      #
      # Logs are stored in the internal array by #write. Logs can be
      # cleared using #flush, which returns the flushed logs too.
      class ArrayOutputter < Log4r::Outputter
        # Include "memoize" class method to memoize methods
        extend Memoist

        # Force the outputter to receive and store all levels of messages
        def level
          Log4r::ALL
        end

        # The internal array of messages
        def messages
          []
        end
        memoize :messages

        # Clear internal log messages array and return the erased data
        def flush
          messages.dup.tap { messages.clear }
        end

        private

          # Write a message to the internal array
          #
          # This is an abstract method in the parent class, and handles
          # persisting the log data. In this class, it saves the message
          # into an internal array to be retrieved later.
          #
          #   * message: The log message to be persisted
          def write(message)
            messages << message
          end
      end
    end
  end
end
