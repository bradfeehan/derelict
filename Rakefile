require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Define "spec" task using RSpec's built-in Rake task
RSpec::Core::RakeTask.new :spec do |spec|
  spec.verbose = false
end

version_major = RbConfig::CONFIG["MAJOR"].to_i
version_minor = RbConfig::CONFIG["MINOR"].to_i
if version_major >= 1 and version_minor >= 9
  require "cane/rake_task"

  # Define "quality" task using Cane's built-in Rake task
  Cane::RakeTask.new :quality do |quality|
    quality.canefile = File.join File.dirname(__FILE__), ".cane"
  end

  task :default => [:spec, :quality]
else
  task :default => :spec
end
