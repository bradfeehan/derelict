module Derelict
  class Connection
    # Represents an invalid connection, which Derelict can't use
    class Invalid < ::Derelict::Exception
      # Initializes a new instance of this exception, with a reason
      #
      #   * reason: Optional explanation of why the connection is
      #             invalid (optional, default text is provided)
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
          "Invalid Derelict connection"
        end
    end
  end
end
