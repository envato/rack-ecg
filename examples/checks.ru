require 'rack/ecg'

use Rack::ECG, checks: [:git_revision, :migration_version]
use Rack::Reloader

run -> (env) { [200, {}, ["Hello, World"]] }
