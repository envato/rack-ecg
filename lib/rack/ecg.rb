require "rack/ecg/version"
require "json"
require "open3"
require "rack/ecg/check"

module Rack
  class ECG
    DEFAULT_MOUNT_AT = "/__healthcheck"
    DEFAULT_MOUNT_PING_AT = "/__ping"
    DEFAULT_CHECKS = { http: true }.freeze

    def initialize(app=nil, options={})
      @app = app

      checks = options.delete(:checks) || {}
      @check_classes = build_check_classes(checks)

      @at = options.delete(:at) || DEFAULT_MOUNT_AT
      @ping_at = options.delete(:ping_at) || DEFAULT_MOUNT_PING_AT
    end

    def call(env)
      if env['PATH_INFO'] == @at

        check_results = @check_classes.map do |check_hash|
          check_klass = check_hash[:class]
          opts = check_hash[:options].is_a?(Hash) && check_hash[:options]
          check = opts ? check_klass.new(opts) : check_klass.new
          begin
            check.result.to_json
          rescue => e
            { service: check_hash[:name], isHealthy: false, message: "Check exception: #{e}" }
          end
        end

        all_healthy = check_results.all? { |check| check[:isHealthy] }

        response_status = all_healthy ? 200 : 500

        response_headers = {
          'X-Rack-ECG-Version'  => Rack::ECG::VERSION,
          'Content-Type'        => 'application/json'
        }

        response_body = JSON.pretty_generate(
          isHealthy: all_healthy,
          healthChecks: check_results.inject({}) { | h, check | h.merge(check[:service] => check) }
        )

        [response_status, response_headers, [response_body]]
      elsif env['PATH_INFO'] == @ping_at
        [200, {}, ['OK']]
      elsif @app
        @app.call(env)
      else
        [404, {}, []]
      end
    end

    private

    def build_check_classes(checks)
      checks.merge!(DEFAULT_CHECKS) # add default checks
      checks.map do |check_name, check_options|
        check_class = CheckRegistry.instance[check_name]
        raise "Don't know about check #{check_name}" unless check_class
        { class: check_class, name: check_name, options: check_options }
      end
    end
  end
end
