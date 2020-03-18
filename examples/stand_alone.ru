# frozen_string_literal: true
require 'rack/ecg'

run(Rack::ECG.new)
