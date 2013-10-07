module Derelict
  class Instance
    # Represents an invalid instance, which can't be used with Derelict
    class Invalid < ::Derelict::Exception
      # Initializes a new instance of this exception, with a reason
      #
      #   * reason: Optional explanation of why the instance is invalid
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
          "Invalid Derelict instance"
        end
    end
  end
end
