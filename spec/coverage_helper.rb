if ENV['TRAVIS']
  # Running on Travis CI: initialize Coveralls to submit coverage data
  require "coveralls"
  Coveralls.wear!
else
  # Not running on Travis CI: Run SimpleCov locally for coverage data
  # Since SimpleCov requires Ruby 1.9+, only include it if we're
  # running on a compatible version.
  version_major = RbConfig::CONFIG["MAJOR"].to_i
  version_minor = RbConfig::CONFIG["MINOR"].to_i
  if version_major >= 2 or (version_major == 1 and version_minor >= 9)
    require "simplecov"
    SimpleCov.start do
      add_filter "/spec/"
      add_filter "/vendor/"
    end
  end
end

