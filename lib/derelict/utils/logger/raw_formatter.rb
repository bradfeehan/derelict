module Derelict
  module Utils
    module Logger
      # A Formatter that passes the log message through untouched
      class RawFormatter < Log4r::Formatter
        def format(event)
          event.data
        end
      end
    end
  end
end
