# frozen_string_literal: true
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
YARD::Rake::YardocTask.new

task(default: [:rubocop, :spec, :yard])

task(:'yard:server') do
  sh "yard server --watch"
end
