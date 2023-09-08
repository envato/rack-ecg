# frozen_string_literal: true

require "rack/ecg/version"
require "json"
require "open3"
require "rack/ecg/check_factory"

module Rack
  class ECG
    # Default mount path.
    DEFAULT_MOUNT_AT = "/_ecg"
    # Checks enabled by default.
    DEFAULT_CHECKS = [:http]
    # Default failure response status.
    DEFAULT_FAILURE_STATUS = 500

    # Constructs an instance of ECG Rack middleware with the specified
    # options.
    #
    # @param app [Object,nil] Underlying Rack application to receive unmatched
    #   requests. If unset, any unmatched requests will return a 404.
    # @param checks [Array<Symbol, Array<Symbol, Object>>] Sets and
    #   configures the checks run by this instance.
    # @param at [String, nil] Path which this ECG instance handles.
    # @param hook [#call, nil] Callable which receives the success status and
    #   check results
    # @param failure_status [Integer] Status code to return on check failure
    def initialize(app = nil, checks: DEFAULT_CHECKS, at: DEFAULT_MOUNT_AT, hook: nil,
      failure_status: DEFAULT_FAILURE_STATUS)
      @app = app

      check_configuration = checks || []
      @check_factory = CheckFactory.new(check_configuration, DEFAULT_CHECKS)
      @mount_at = at || DEFAULT_MOUNT_AT

      @result_hook = hook

      @failure_response_status = failure_status
    end

    # Rack compatible call method. Not intended for direct usage.
    def call(env)
      if env["PATH_INFO"] == @mount_at
        check_results = @check_factory.build_all.inject({}) do |results, check|
          results.merge(check.result.as_json)
        end

        success = check_results.none? { |check| check[1][:status] == Check::Status::ERROR }

        response_status = success ? 200 : @failure_response_status

        @result_hook&.call(success, check_results)

        response_headers = {
          "X-Rack-ECG-Version" => Rack::ECG::VERSION,
          "Content-Type" => "application/json",
        }

        response_body = JSON.pretty_generate(check_results)

        [response_status, response_headers, [response_body]]
      elsif @app
        @app.call(env)
      else
        [404, {}, []]
      end
    end
  end
end
