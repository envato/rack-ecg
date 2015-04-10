require 'rack/ecg'

use Rack::ECG, at: "/health_check"

run -> (env) { [200, {}, ["Hello, World"]] }
