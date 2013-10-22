module Derelict
  class Instance
    # Represents an invalid instance, which can't be used with Derelict
    class Invalid < ::Derelict::Exception
      include Derelict::Exception::OptionalReason

      private
        # Retrieves the default error message
        def default_message
          "Invalid Derelict instance"
        end
    end
  end
end
