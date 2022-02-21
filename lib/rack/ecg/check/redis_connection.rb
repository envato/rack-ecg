# frozen_string_literal: true
module Rack
  class ECG
    module Check
      # @!method initialize
      #   Checks whether the given Redis client is currently connected to the
      #   database as identified by the ++instance++ option.
      #
      # @option parameters instance [Redis,Hash] Redis parameters to check
      class RedisConnection
        attr_reader :redis_instance

        def initialize(parameters = {})
          @redis_instance = parameters[:instance]
        end

        def result
          value = ""
          status = Status::OK
          begin
            if redis_instance.nil?
              status = Status::ERROR
              value = "Redis instance parameters not found"
            elsif defined?(::Redis)
              value = redis_instance.connected?
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
