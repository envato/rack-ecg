require 'rack/ecg'

use Rack::ECG, at: "/health_check"
use Rack::Reloader

run -> (env) { [200, {}, ["Hello, World"]] }
