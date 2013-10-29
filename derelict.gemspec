# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "derelict/version"

Gem::Specification.new do |spec|
  spec.name          = "derelict"
  spec.version       = Derelict::VERSION
  spec.authors       = ["Brad Feehan"]
  spec.email         = ["git@bradfeehan.com"]
  spec.description   = <<-END.strip.gsub(/ +/, " ").gsub(/^ /, "")
    Provides a Ruby API to control Vagrant where Vagrant is         \
    installed via the Installer package on Mac OS X.

    Vagrant was historically available as a gem, naturally          \
    providing a Ruby API to control Vagrant in other Ruby libraries \
    and applications. However, since version 1.1.0, Vagrant is      \
    distributed exclusively using an Installer package. To control  \
    Vagrant when it's installed this way, other Ruby libraries and  \
    applications typically need to invoke the Vagrant binary, which \
    requires forking a new process and parsing its output using     \
    string manipulation.
  END

  spec.summary       =
    "Ruby API for Vagrant installed via Installer package on Mac OS X."
  spec.homepage      = "https://github.com/bradfeehan/derelict"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "log4r"
  spec.add_runtime_dependency "memoist"
  spec.add_runtime_dependency "shell-executer"


  version_major = RbConfig::CONFIG["MAJOR"].to_i
  version_minor = RbConfig::CONFIG["MINOR"].to_i
  cane_supported = (version_major >= 2 or (version_major == 1 and version_minor >= 9))

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "cane" if cane_supported
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "its"
  spec.add_development_dependency "mime-types", "<2.0" # for coveralls

  # When running on Travis CI, any passing builds will be deployed
  # (i.e. pushed to RubyGems). This changes the version number so that
  # these deployments are marked as pre-release versions (which will
  # occur if the version number has a letter in it, so we add
  # "travis" followed by the job number to the version string).
  # So version 1.2.3 will be marked as (e.g.) "1.2.4.travis.567".
  if ENV["TRAVIS"]
    build = ENV["TRAVIS_JOB_NUMBER"].split(".").first
    spec.version = "#{spec.version.to_s.succ}.travis.#{build}"
  end
end
