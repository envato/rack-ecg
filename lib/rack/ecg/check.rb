require "rack/ecg/check_registry"
require "rack/ecg/check/constant"
require "rack/ecg/check/error"
require "rack/ecg/check/git_revision"
require "rack/ecg/check/http"
require "rack/ecg/check/migration_version"

module Rack
  class ECG
    module Check
      class Result < Struct.new(:service_name, :status, :value)
        def to_json
          { service: service_name, isHealthy: status, message: value }
        end
      end
    end
  end
end
