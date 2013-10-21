module Derelict
  # A namespaced collection of utilities for general purpose use
  #
  # Derelict::Utils contains all the individual sub-modules inside it.
  module Utils
    autoload :Logger,    "derelict/utils/logger"

    # Include sub-modules here
    include Derelict::Utils::Logger
  end
end
