# frozen_string_literal: true

begin
  require "bundler/gem_tasks"
rescue LoadError
  # not a significant issue
end

require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
YARD::Rake::YardocTask.new

task(default: [:rubocop, :spec, :yard])

task(:watch_docs) do
  sh "yard server --reload"
end
