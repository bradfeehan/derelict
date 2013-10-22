module Derelict
  class Connection
    # Represents an invalid connection, which Derelict can't use
    class Invalid < Derelict::Exception
      include Derelict::Exception::OptionalReason

      private
        # Retrieves the default error message
        def default_message
          "Invalid Derelict connection"
        end
    end
  end
end
