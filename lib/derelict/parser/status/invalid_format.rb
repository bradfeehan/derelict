module Derelict
  class Parser
    class Status
      # The status wasn't in the expected format and couldn't be parsed
      class InvalidFormat < Derelict::Exception
        include Derelict::Exception::OptionalReason

        private
          # Retrieves the default error message
          def default_message
            "Output from 'vagrant status' was in an unexpected format"
          end
      end
    end
  end
end
