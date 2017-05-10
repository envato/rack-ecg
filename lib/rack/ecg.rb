require "rack/ecg/version"
require "json"
require "open3"
require "rack/ecg/check_factory"

module Rack
  class ECG
    DEFAULT_MOUNT_AT = "/_ecg"
    DEFAULT_CHECKS = [ :http ]

    def initialize(app=nil, options={})
      @app = app

      check_configuration = options.delete(:checks) || []
      @check_factory = CheckFactory.new(check_configuration, DEFAULT_CHECKS)
      @at = options.delete(:at) || DEFAULT_MOUNT_AT

      @hook = options.delete(:hook)
    end

    def call(env)
      if env["PATH_INFO"] == @at
        check_results = @check_factory.build_all.inject({}) do |results, check|
          results.merge(check.result.to_json)
        end

        success = check_results.none? { |check| check[1][:status] == "error" }

        response_status = success ? 200 : 500

        @hook.call(success, check_results) if @hook

        response_headers = {
          "X-Rack-ECG-Version"  => Rack::ECG::VERSION,
          "Content-Type"        => "application/json"
        }

        response_body = JSON.pretty_generate(check_results)

        [response_status, response_headers, [response_body]]
      elsif @app
        @app.call(env)
      else
        [404, {},[]]
      end
    end
  end
end
