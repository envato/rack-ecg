# frozen_string_literal: true

module Rack
  class ECG
    module Check
      class SequelConnection
        attr_reader :connection_parameters, :name

        # Checks whether Sequel can connect to the database identified by the
        # ++connection++ option.
        #
        # @option parameters connection [String,Hash] Sequel connection parameters to check
        # @option parameters name [String,nil] Name to distinguish multiple Sequel checks
        def initialize(parameters = {})
          @connection_parameters = parameters[:connection]
          @name = parameters[:name]
        end

        def result
          value = ""
          status = Status::OK
          begin
            if connection_parameters.nil?
              status = Status::ERROR
              value = "Sequel Connection parameters not found"
            elsif defined?(::Sequel)
              ::Sequel.connect(connection_parameters) do |db|
                value = db.test_connection
                status = Status::OK
              end
            else
              status = Status::ERROR
              value = "Sequel not found"
            end
          rescue => e
            status = Status::ERROR
            value = e.message
          end

          Result.new(result_key.to_sym, status, value.to_s)
        end

        def result_key
          if name
            "sequel #{name.downcase}".gsub(/\W+/, "_")
          else
            "sequel"
          end
        end

        CheckRegistry.instance.register(:sequel, SequelConnection)
      end
    end
  end
end
