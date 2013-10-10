module Derelict
  class VirtualMachine
    # The requested virtual machine isn't defined in the Vagrantfile
    class NotFound < Invalid
      # Initializes a new instance of this exception for a given name
      #
      #   * connection: The Derelict connection used for this VM
      #   * name:       The requested name of the virtual machine
      def initialize(connection, name)
        super "Virtual machine #{name} not found in #{connection.path}"
      end
    end
  end
end
