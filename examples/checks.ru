require 'rack/ecg'

use Rack::ECG, checks: [:git_revision, :migration_version]

run -> (env) { [200, {}, ["Hello, World"]] }
