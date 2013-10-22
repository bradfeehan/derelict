module Derelict
  class VirtualMachine
    # Represents an invalid virtual machine, which Derelict can't use
    class Invalid < ::Derelict::Exception
      include Derelict::Exception::OptionalReason

      private
        # Retrieves the default error message
        def default_message
          "Invalid Derelict virtual machine"
        end
    end
  end
end
