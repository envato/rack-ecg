module Rack
  class ECG
    module Check
      class MigrationVersion
        def result
          value = ""
          status = true
          begin
            if defined?(ActiveRecord)
              connection = ActiveRecord::Base.connection
              value = connection.select_value("select max(version) from schema_migrations")
              # Assuming you're using Rails if you're using ActiveRecord Migrations
              max_migration = Dir.glob(Rails.root.to_s + "/db/migrate/*.rb").map{|file| file.split('/').last.split('_').first.to_i }.max
              if value.to_s != max_migration.to_s
                status = false
                value = "Migrations not up to date. Max: #{max_migration} Current: #{value}"
              end
            else
              status = false
              value = "ActiveRecord not found"
            end
          rescue => e
            status = false
            value = e.message
          end

          Result.new(:migration_version, status, value)
        end
      end

      CheckRegistry.instance.register(:migration_version, MigrationVersion)

    end
  end
end
