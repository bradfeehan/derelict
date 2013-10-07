module Derelict
  class Instance
    # The path used for the instance was a file, not a directory
    class NonDirectory < Invalid
      # Initializes a new instance of this exception for a given path
      #
      #   * path: The requested path of the instance
      def initialize(path)
        super "expected directory, found file: #{path}"
      end
    end
  end
end
