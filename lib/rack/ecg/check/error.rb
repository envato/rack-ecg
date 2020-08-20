# frozen_string_literal: true
module Rack
  class ECG
    module Check
      # @!method initialize
      #   Always returns a basic error for testing purposes.
      class Error
        def result
          Result.new(:error, Status::ERROR, "PC LOAD LETTER")
        end
      end

      CheckRegistry.instance.register(:error, Error)
    end
  end
end
