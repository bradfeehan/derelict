module Derelict
  module Logger
    # The "type" option when requesting the logger was invalid
    class InvalidType < ::Derelict::Exception
      # Initializes a new instance of this exception for a type
      #
      #   * type: The (invalid) requested type
      def initialize(type)
        super "Invalid logger type '#{type}'"
      end
    end
  end
end
