module Rack
  class ECG
    module Check
      # if rack-ecg is serving a request - http is obviously working so far...
      # this is basically a "hello-world"
      class Error
        def result
          Result.new(:error, "error", "PC LOAD LETTER")
        end
      end
    end
  end
end
