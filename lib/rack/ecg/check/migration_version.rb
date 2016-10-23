module Rack
  class ECG
    module Check
      class MigrationVersion
        def result
          value = ""
          status = "ok"
          begin
            if defined?(ActiveRecord)
              connection = ActiveRecord::Base.connection
              value = connection.select_value("select max(version) from schema_migrations")
            else
              status = "error"
              value = "ActiveRecord not found"
            end
          rescue => e
            status = "error"
            value = e.message
          end

          Result.new(:migration_version, status, value)
        end
      end

      CheckRegistry.instance.register(:migration_version, MigrationVersion)

    end
  end
end
