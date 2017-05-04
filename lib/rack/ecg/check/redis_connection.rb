module Rack
  class ECG
    module Check
      class RedisConnection
        def result
          value = ""
          status = "ok"
          begin
            if defined?(::Redis)
              value = ::Redis.current.connected?
              status = value ? "ok" : "error"
            else
              status = "error"
              value = "Redis not found"
            end
          rescue => e
            status = "error"
            value = e.message
          end

          Result.new(:redis, status, value.to_s)
        end

        CheckRegistry.instance.register(:redis, RedisConnection)
      end
    end
  end
end
