module Derelict
  class Box
    # A box that isn't currently installed has been retrieved
    class NotFound < Derelict::Exception
      # Initializes a new instance, for a particular box name/provider
      #
      #   * box_name: The name of the box that this exception relates
      #               to
      #   * provider: The provider of the box that this exception
      #               relates to
      def initialize(box_name, provider)
        super "Box '#{box_name}' for provider '#{provider}' missing"
      end
    end
  end
end
