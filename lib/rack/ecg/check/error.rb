module Rack
  class ECG
    module Check

      class Error
        def result
          Result.new(:error, false, "PC LOAD LETTER")
        end
      end

      CheckRegistry.instance.register(:error, Error)
    end
  end
end
