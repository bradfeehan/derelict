module Derelict
  class Parser
    class PluginList
      # Vagrant plugins need to be uninstalled and re-installed
      class NeedsReinstall < Derelict::Exception
        # Retrieves the output from Vagrant
        attr_reader :output

        # Initializes a new instance, for a particular box name/provider
        #
        #   * output: The output from Vagrant
        def initialize(output)
          @output = output
          super <<-END.gsub(/\s+/, ' ').strip
            Vagrant plugins installed before upgrading to version 1.4.x
            need to be uninstalled and re-installed.
          END
        end
      end
    end
  end
end
