# frozen_string_literal: true
require "rack/ecg"

use(Rack::ECG, at: "/health_check")

run(-> (_env) { [200, {}, ["Hello, World"]] })
