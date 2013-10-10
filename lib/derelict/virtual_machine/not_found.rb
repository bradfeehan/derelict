module Derelict
  class VirtualMachine
    # The requested virtual machine isn't defined in the Vagrantfile
    class NotFound < Invalid
      # Initializes a new instance of this exception for a given name
      #
      #   * connection: The Derelict connection used for this VM
      #   * name:       The requested name of the virtual machine
      def initialize(connection, name)
        if connection.respond_to? :path
          super "Virtual machine #{name} not found in #{connection.path}"
        else
          super "Virtual machine #{name} not found"
        end
      end
    end
  end
end
