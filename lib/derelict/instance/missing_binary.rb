module Derelict
  class Instance
    # The "vagrant" binary was missing from the instance
    class MissingBinary < Invalid
      # Initializes a new instance of this exception for a given file
      #
      #   * file: The expected location of the binary
      def initialize(file)
        super "'vagrant' binary not found at #{file}"
      end
    end
  end
end
