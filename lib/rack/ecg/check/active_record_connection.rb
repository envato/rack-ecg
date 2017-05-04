module Rack
  class ECG
    module Check
      class ActiveRecordConnection
        def result
          value = ""
          status = "ok"
          begin
            if defined?(ActiveRecord)
              value = ::ActiveRecord::Base.connection.active?
              status = value ? "ok" : "error"
            else
              status = "error"
              value = "ActiveRecord not found"
            end
          rescue => e
            status = "error"
            value = e.message
          end

          Result.new(:active_record, status, value.to_s)
        end

        CheckRegistry.instance.register(:active_record, ActiveRecordConnection)
      end
    end
  end
end
