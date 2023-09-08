# frozen_string_literal: true

require "rack/ecg"

use(
  Rack::ECG,
  checks: [:error],
  failure_status: 503,
)

run(->(_env) { [200, {}, ["Hello, World"]] })
