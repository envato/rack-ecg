# frozen_string_literal: true
require "rack/ecg/check_registry"
require "rack/ecg/check/active_record_connection"
require "rack/ecg/check/error"
require "rack/ecg/check/git_revision"
require "rack/ecg/check/http"
require "rack/ecg/check/migration_version"
require "rack/ecg/check/redis_connection"
require "rack/ecg/check/sequel_connection"
require "rack/ecg/check/static"

module Rack
  class ECG
    module Check
      # Possible recognised check statuses.
      module Status
        # Indicates the check was successful.
        OK = "ok"
        # Indicates the check errored.
        ERROR = "error"
      end

      class Result < Struct.new(:name, :status, :value)
        # Format the result as a JSON compatible hash.
        #
        # @return [Hash<Object, Hash<Symbol, Object>>] Result in a hash format.
        # @example A HTTP success response
        #   puts result.as_json
        #   # {:http=>{:status=>"ok", :value=>"online"}}
        def as_json
          { name => { status: status, value: value } }
        end

        # Return the result as a JSON object.
        #
        # @return [String] Result in a JSON object string.
        # @example A HTTP success response
        #   puts result.to_json
        #   # {"http": {"status": "ok", "value": "online"}}
        def to_json
          JSON.dump(as_json)
        end
      end
    end
  end
end
