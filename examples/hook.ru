# frozen_string_literal: true

require 'rack/ecg'

log_check_results = proc do |success, checks|
  next if success

  checks.each do |check_name, check_status|
    next unless check_status[:status] == 'error'

    puts "Check #{check_name} failed: #{check_status[:value]}"
  end
end

use Rack::ECG, checks: [:git_revision, :migration_version], hook: log_check_results

run ->(env) { [200, {}, ['Hello, World']] }
