module Derelict
  class Instance
    # Represents an invalid instance, which can't be used with Derelict
    class CommandFailed < Derelict::Exception
      # Initializes a new instance of this exception, for a command
      #
      #   * command: The name of the command which failed (optional,
      #              provides extra detail in the message)
      #   * result:  The result (Derelict::Executer) for the command
      #              which failed (optional, provides extra detail in
      #              the message)
      def initialize(command = nil, result = nil)
        super [default_message, describe(command, result)].join
      end

      private
        # Retrieves the default error message
        def default_message
          "Error executing Vagrant command"
        end

        def describe(command = nil, result = nil)
          [
            command.nil? ? "" : " '#{command}'",
            result.nil? ? "" : ", STDERR output:\n#{result.stderr}",
          ].join
        end
    end
  end
end
