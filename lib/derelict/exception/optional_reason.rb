module Derelict
  class Exception
    # An exception that has a message and optional additional reason
    #
    # The reason can be passed to the constructor (if desired). When a
    # reason is passed, it's appended to the default message. If no
    # reason is passed, the default message is used.
    module OptionalReason
      # Initializes a new instance of this exception, with a reason
      #
      #   * reason: Optional reason to add to the default error message
      #             (optional, the default message will be used if no
      #             reason is provided)
      def initialize(reason = nil)
        if reason.nil?
          super default_message
        else
          super "#{default_message}: #{reason}"
        end
      end

      private
        # Retrieves the default error message
        #
        # This needs to be overridden in child classes in order to
        # customize the default error message.
        def default_message
          raise NotImplementedError.new "#default_message not defined"
        end
    end
  end
end
