require "rack/ecg/version"
require "json"

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
        facts = {
          "git_revision" => git_revision,
          "migration_version" => migration_version
        }
        [200, {"X-Rack-ECG-Version" => Rack::ECG::VERSION}, [JSON.dump(facts)]]
      else
        @app.call(env)
      end
    end

    private
    def git_revision
      sha = `git rev-parse HEAD`
      if $?.success?
        sha
      else
        "unknown"
      end
    end

    def migration_version
      if defined?(ActiveRecord)
        connection = ActiveRecord::Base.connection
        result_set = connection.execute("select max(version) as version from schema_migrations")
        version = result_set.first
        version["version"]
      else
        "unknown"
      end
    end
  end
end
