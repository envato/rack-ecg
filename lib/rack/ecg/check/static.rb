# frozen_string_literal: true
module Rack
  class ECG
    module Check
      class Static
        # Always returns the provided ++value++ under the ++name++ key, with the result set by ++status++.
        #
        # @example Return "Hello, world!" under ++static++
        #   use(Rack::ECG, { checks: [[:static, { value: "Hello, world!" }]] })
        #
        # @example Return "Paper jam in tray 2" as an error under ++printer_status++
        #   use(Rack::ECG, {
        #     checks: [
        #       [
        #         :static,
        #         {
        #           value: "Paper jam in tray 2",
        #           success: false, # or status: Rack::ECG::Check::Status::ERROR
        #           name: :printer_status,
        #         },
        #       ],
        #     ],
        #   })
        #
        # @option parameters value [Object] (nil) Result value
        # @option parameters status [Status::ERROR, Status::OK, nil] (nil) Result status (takes precedence over
        #   ++success++)
        # @option parameters success [Boolean] (true) Whether the result is successful
        # @option parameters name [Symbol, #to_sym] (:static) Key for the check result in the response
        def initialize(parameters)
          parameters ||= {}

          @name = parameters.fetch(:name, :static).to_sym
          @value = parameters.fetch(:value, nil)

          @status = if parameters.key?(:status)
            parameters[:status]
          else
            parameters.fetch(:success, true) ? Status::OK : Status::ERROR
          end
        end

        def result
          Result.new(@name, @status, @value)
        end
      end

      CheckRegistry.instance.register(:static, Static)
    end
  end
end
