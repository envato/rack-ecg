require "rack/ecg/version"
require "json"
require "open3"
require "rack/ecg/check"

module Rack
  class ECG
    DEFAULT_MOUNT_AT = "/_ecg"
    DEFAULT_CHECKS = [ :http ]

    def initialize(app=nil, options={})
      @app = app

      check_names = options.delete(:checks) || []
      @check_classes = build_check_classes(check_names)

      @at = options.delete(:at) || DEFAULT_MOUNT_AT

      @hook = options.delete(:hook)
    end

    def call(env)
      if env["PATH_INFO"] == @at

        check_results = @check_classes.inject({}){|results, check_class|
          check = check_class.new
          results.merge(check.result.to_json)
        }

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

    private
    def build_check_classes(check_names)
      check_names = Array(check_names) # handle nil, or not a list
      check_names = check_names | DEFAULT_CHECKS # add the :http check if it's not there
      check_names.map{|check_name|
        check_class = CheckRegistry.instance[check_name]
        raise "Don't know about check #{check_name}" unless check_class
        check_class
      }
    end
  end
end
