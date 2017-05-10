module Rack
  class ECG
    module Check
      # if rack-ecg is serving a request - http is obviously working so far...
      # this is basically a "hello-world"
      class Http
        def result
          Result.new(:http, Status::OK, "online")
        end
      end

      CheckRegistry.instance.register(:http, Http)

    end
  end
end
