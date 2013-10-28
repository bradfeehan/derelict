module Derelict
  class Plugin
    # A plugin that isn't currently installed has been retrieved
    class NotFound < Derelict::Exception
      # Initializes a new instance of this exception, for a plugin name
      #
      #   * plugin_name: The name of the plugin that this exception
      #                  relates to
      def initialize(plugin_name)
        super "Plugin '#{plugin_name}' is not currently installed"
      end
    end
  end
end
