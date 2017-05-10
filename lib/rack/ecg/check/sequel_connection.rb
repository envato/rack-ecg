module Rack
  class ECG
    module Check
      class SequelConnection
        attr_reader :connection_parameters, :name
        def initialize(parameters = {})
          @connection_parameters = parameters[:connection]
          @name = parameters[:name]
        end

        def result
          value = ""
          status = "ok"
          begin
            if connection_parameters.nil?
              status = "error"
              value = "Sequel Connection parameters not found"
            elsif defined?(Sequel)
              ::Sequel.connect(connection_parameters) { |db|
                value = db.test_connection
                status = "#{name || db.inspect} #{value ? "ok" : "error"}"
              }
            else
              status = "error"
              value = "Sequel not found"
            end
          rescue => e
            status = "error"
            value = e.message
          end

          Result.new("sequel #{name.downcase}".gsub(/\W+/, '_').to_sym, status, value.to_s)
        end

        CheckRegistry.instance.register(:sequel, SequelConnection)
      end
    end
  end
end
