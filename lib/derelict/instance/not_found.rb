module Derelict
  class Instance
    # The path used for the instance was not found
    class NotFound < Invalid
      # Initializes a new instance of this exception for a given path
      #
      #   * path: The requested path of the instance
      def initialize(path)
        super "directory doesn't exist: #{path}"
      end
    end
  end
end
