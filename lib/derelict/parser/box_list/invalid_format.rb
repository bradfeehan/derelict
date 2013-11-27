module Derelict
  class Parser
    class BoxList
      # The box list wasn't in the expected format, can't be parsed
      class InvalidFormat < Derelict::Exception
        include Derelict::Exception::OptionalReason

        private
          # Retrieves the default error message
          def default_message
            "Output from 'vagrant box list' was in an unexpected format"
          end
      end
    end
  end
end
