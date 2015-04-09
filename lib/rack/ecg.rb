require "rack/ecg/version"
require "json"
require "open3"
require "rack/ecg/check"

module Rack
  class ECG
    DEFAULT_MOUNT_AT = "/_ecg"
    DEFAULT_CHECKS = [ :check_http ]

    def initialize(app, options={})
      @app = app
      option_checks = options.delete(:checks) || []
      option_checks = option_checks.map{|check| "check_#{check}".to_sym }
      @checks = DEFAULT_CHECKS + option_checks
      @at = options.delete(:at) || DEFAULT_MOUNT_AT
    end

    def call(env)
      if env["PATH_INFO"] == @at

        check_results = @checks.inject({}){|results, check_method| results.merge(send(check_method)) }

        response_status = check_results.any?{|check| check[1][:status] == "error" } ? 500 : 200

        response_headers = {
          "X-Rack-ECG-Version"  => Rack::ECG::VERSION,
          "Content-Type"        => "application/json"
        }

        response_body = JSON.pretty_generate(check_results)

        [response_status, response_headers, [response_body]]
      else
        @app.call(env)
      end
    end

    private
    def check_http
      # if rack-ecg is serving a request - http is obviously working so far...
      # this is basically a "hello-world"
      {http: {status: "ok", value: "online" } }
    end

    def check_error
      # this always fails. mainly for testing
      {error: {status: "error", value: "PC LOAD LETTER" } }
    end

    def check_git_revision
      check = Check::GitRevision.new
      check.result.to_json
    end

    def check_migration_version
      value = ""
      status = "ok"
      begin
        if defined?(ActiveRecord)
          connection = ActiveRecord::Base.connection
          result_set = connection.execute("select max(version) as version from schema_migrations")
          version = result_set.first
          value = version["version"]
        else
          status = "error"
          value = "ActiveRecord not found"
        end
      rescue => e
        status = "error"
        value = e.message
      end
      {migration_version: {status: status, value: value} }
    end
  end
end
