# frozen_string_literal: true

require_relative "./static"

module Rack
  class ECG
    module Check
      # @!method initialize
      #   Always returns a basic error for testing purposes.
      class Error < Static
        STATIC_PARAMETERS = {
          name: :error,
          success: false,
          value: "PC LOAD LETTER",
        }.freeze

        def initialize
          super(STATIC_PARAMETERS)
        end
      end

      CheckRegistry.instance.register(:error, Error)
    end
  end
end
