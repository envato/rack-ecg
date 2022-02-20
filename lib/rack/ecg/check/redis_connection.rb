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
        attr_reader :instance_parameters

        def initialize(parameters = {})
          @instance_parameters = parameters[:instance]
        end

        def result
          value = ""
          status = Status::OK
          begin
            if instance_parameters.nil?
              status = Status::ERROR
              value = "Redis instance parameters not found"
            elsif defined?(::Redis)
              value = instance_parameters.connected?
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
