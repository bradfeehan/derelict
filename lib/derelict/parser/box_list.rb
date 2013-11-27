module Derelict
  # Parses the output of "vagrant box list"
  class Parser::BoxList < Parser
    autoload :InvalidFormat, "derelict/parser/box_list/invalid_format"
  end
end
