module Derelict
  class Parser
    class Status
      # The status wasn't in the expected format and couldn't be parsed
      class InvalidFormat < ::Derelict::Exception
        # Initializes a new instance of this exception, with a reason
        #
        #   * reason: Optional explanation of why the format is invalid
        #             (optional, default text is provided)
        def initialize(reason = nil)
          if reason.nil?
            super default_message
          else
            super "#{default_message}: #{reason}"
          end
        end

        private
          # Retrieves the default error message
          def default_message
            "Output from 'vagrant status' was in an unexpected format"
          end
      end
    end
  end
end
