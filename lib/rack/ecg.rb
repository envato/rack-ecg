require "rack/ecg/version"
require "json"
require "open3"

module Rack
  class ECG
    DEFAULT_MOUNT_AT = "/_ecg"

    attr_reader :at

    def initialize(app, options={})
      @app = app
      @at = options.delete(:at) || DEFAULT_MOUNT_AT
    end

    def call(env)
      if env["PATH_INFO"] == at

        checks = {}
        checks = checks.merge(git_revision)
        checks = checks.merge(migration_version)

        [200, {"X-Rack-ECG-Version" => Rack::ECG::VERSION}, [JSON.pretty_generate(checks)]]
      else
        @app.call(env)
      end
    end

    private
    def git_revision
      _stdin, stdout, stderr, wait_thread = Open3.popen3("git rev-parse HEAD")

      success = wait_thread.value.success?
      status = success ? "ok" : "error"
      value = success ? stdout.read : stderr.read
      {git_revision: {status: status, value: value} }
    end

    def migration_version
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
