module Rack
  class ECG
    module Check
      # if rack-ecg is serving a request - http is obviously working so far...
      # this is basically a "hello-world"
      class Error
        def result
          Result.new(:error, Status::ERROR, "PC LOAD LETTER")
        end
      end

      CheckRegistry.instance.register(:error, Error)

    end
  end
end
