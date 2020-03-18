# frozen_string_literal: true
require "rack/ecg/check_registry"
require "rack/ecg/check/error"
require "rack/ecg/check/git_revision"
require "rack/ecg/check/http"
require "rack/ecg/check/migration_version"
require "rack/ecg/check/active_record_connection"
require "rack/ecg/check/redis_connection"
require "rack/ecg/check/sequel_connection"

module Rack
  class ECG
    module Check
      module Status
        OK = "ok"
        ERROR = "error"
      end

      class Result < Struct.new(:name, :status, :value)
        def to_json
          { name => { status: status, value: value } }
        end
      end
    end
  end
end
