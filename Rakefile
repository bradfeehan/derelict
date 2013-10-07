require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Define "spec" task using RSpec's built-in Rake task
RSpec::Core::RakeTask.new :spec do |spec|
  spec.verbose = false
end

# Make "spec" the default task
task :default => :spec
