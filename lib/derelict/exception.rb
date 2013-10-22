module Derelict
  # Base class for any exceptions thrown by Derelict
  class Exception < ::Exception
    autoload :OptionalReason, "derelict/exception/optional_reason"
  end
end
