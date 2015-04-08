require 'rack-ecg'

use Rack::ECG
use Rack::Reloader

run -> (env) { [200, {}, ["Hello, World"]] }
