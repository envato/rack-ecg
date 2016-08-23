module Rack
  class ECG
    module Check
      # if rack-ecg is serving a request - http is obviously working so far...
      # this is basically a "hello-world"
      class Constant
        def initialize(options)
          @options = options
        end

        def result
          const = Kernel.const_get(@options[:name])
          Result.new(:constant, "ok", const)
        rescue NameError
          Result.new(:constant, "error", "Constant ( #{@options[:name]} ) missing")
        end
      end

      CheckRegistry.instance.register(:constant, Constant)
    end
  end
end
