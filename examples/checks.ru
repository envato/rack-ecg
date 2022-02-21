# frozen_string_literal: true

require "rack/ecg"

use(Rack::ECG, checks: [:git_revision, :migration_version])

run(->(_env) { [200, {}, ["Hello, World"]] })
