require 'rack/ecg'

use Rack::ECG, mounted_path: "/health_check"
use Rack::Reloader

run -> (env) { [200, {}, ["Hello, World"]] }
