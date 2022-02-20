# frozen_string_literal: true
require_relative "./static"

module Rack
  class ECG
    module Check
      # @!method initialize
      #   Always returns a success.
      class Http < Static
        STATIC_PARAMETERS = {
          name: :http,
          success: true,
          value: "online",
        }.freeze

        def initialize
          super(STATIC_PARAMETERS)
        end
      end

      CheckRegistry.instance.register(:http, Http)
    end
  end
end
