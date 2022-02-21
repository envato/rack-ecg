# frozen_string_literal: true

require "rack/ecg"

use(Rack::ECG)

run(->(_env) { [200, {}, ["Hello, World"]] })
