require "rack/ecg/check_registry"
require "rack/ecg/check/constant"
require "rack/ecg/check/error"
require "rack/ecg/check/git_revision"
require "rack/ecg/check/http"
require "rack/ecg/check/migration_version"

module Rack
  class ECG
    module Check
      class Result < Struct.new(:name, :status, :value)
        def to_json
          { name => { status: status, value: value } }
        end
      end
    end
  end
end
