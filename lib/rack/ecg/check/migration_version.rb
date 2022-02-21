# frozen_string_literal: true

module Rack
  class ECG
    module Check
      # @!method initialize
      #   Returns the latest applied ActiveRecord migration in the default
      #   database.
      class MigrationVersion
        def result
          value = ""
          status = Status::OK
          begin
            if defined?(ActiveRecord)
              connection = ActiveRecord::Base.connection
              value = connection.select_value("select max(version) from schema_migrations")
            else
              status = Status::ERROR
              value = "ActiveRecord not found"
            end
          rescue => e
            status = Status::ERROR
            value = e.message
          end

          Result.new(:migration_version, status, value)
        end
      end

      CheckRegistry.instance.register(:migration_version, MigrationVersion)
    end
  end
end
