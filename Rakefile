require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'

task :noop do; end
task default: :spec

RSpec::Core::RakeTask.new(spec: :noop)
