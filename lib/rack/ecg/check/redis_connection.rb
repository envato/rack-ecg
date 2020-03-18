# frozen_string_literal: true
module Rack
  class ECG
    module Check
      class RedisConnection
        def result
          value = ""
          status = Status::OK
          begin
            if defined?(::Redis)
              value = ::Redis.current.connected?
              status = value ? Status::OK : Status::ERROR
            else
              status = Status::ERROR
              value = "Redis not found"
            end
          rescue => e
            status = Status::ERROR
            value = e.message
          end

          Result.new(:redis, status, value.to_s)
        end

        CheckRegistry.instance.register(:redis, RedisConnection)
      end
    end
  end
end
