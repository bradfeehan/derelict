require "derelict"

derelict_logger = Derelict.logger
array_outputter = Derelict::Log4r::ArrayOutputter.new "rspec"

RSpec.configure do |config|
  config.before :each do
    # Start each spec with an empty ArrayOutputter
    array_outputter.flush

    # Remove any outputters set on other loggers
    Log4r::Logger.each {|fullname, logger| logger.outputters = [] }

    # Add the ArrayOutputter to the base Derelict logger
    derelict_logger.outputters = [array_outputter]
  end
end
