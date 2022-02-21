# frozen_string_literal: true

module Rack
  class ECG
    module Check
      # @!method initialize
      #   Checks whether ActiveRecord is currently connected to the default
      #   database.
      class ActiveRecordConnection
        def result
          value = ""
          status = Status::OK
          begin
            if defined?(ActiveRecord)
              value = ::ActiveRecord::Base.connection.active?
              status = value ? Status::OK : Status::ERROR
            else
              status = Status::ERROR
              value = "ActiveRecord not found"
            end
          rescue => e
            status = Status::ERROR
            value = e.message
          end

          Result.new(:active_record, status, value.to_s)
        end

        CheckRegistry.instance.register(:active_record, ActiveRecordConnection)
      end
    end
  end
end
