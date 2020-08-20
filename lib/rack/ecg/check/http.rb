# frozen_string_literal: true
module Rack
  class ECG
    module Check
      # @!method initialize
      #   Always returns a success.
      class Http
        def result
          Result.new(:http, Status::OK, "online")
        end
      end

      CheckRegistry.instance.register(:http, Http)
    end
  end
end
