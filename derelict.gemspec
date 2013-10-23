# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "derelict/version"

Gem::Specification.new do |spec|
  spec.name          = "derelict"
  spec.version       = Derelict::VERSION
  spec.authors       = ["Brad Feehan"]
  spec.email         = ["git@bradfeehan.com"]
  spec.description   = [
    "Provides a Ruby API to control Vagrant where Vagrant is ",
    "installed via the Installer package on Mac OS X.",
    "\n\n",
    "Vagrant was historically available as a gem, naturally ",
    "providing a Ruby API to control Vagrant in other Ruby libraries ",
    "and applications. However, since version 1.1.0, Vagrant is ",
    "distributed exclusively using an Installer package. To control ",
    "Vagrant when it's installed this way, other Ruby libraries and ",
    "applications typically need to invoke the Vagrant binary, which ",
    "requires forking a new process and parsing its output using ",
    "string manipulation.",
  ].join,
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
  cane_supported = (version_major >= 1 and version_minor >= 9)

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "cane" if cane_supported
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "its"
end
