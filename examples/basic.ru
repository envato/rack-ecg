require 'rack/ecg'

use Rack::ECG

run -> (env) { [200, {}, ["Hello, World"]] }
