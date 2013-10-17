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

  # Forbid .should syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
