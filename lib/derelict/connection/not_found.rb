module Derelict
  class Connection
    # The Vagrantfile for the connection was not found
    class NotFound < Invalid
      # Initializes a new instance of this exception for a given path
      #
      #   * path: The requested path of the instance
      def initialize(path)
        super "Vagrantfile not found for #{path}"
      end
    end
  end
end
