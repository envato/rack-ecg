module Rack
  class ECG
    module Check
      class Constant
        def initialize(options)
          @options = options
        end

        def result
          label = @options[:label]
          const = Kernel.const_get(@options[:name])
          Result.new(label, true, const)
        rescue NameError
          Result.new(label, false, "Constant ( #{@options[:name]} ) missing")
        end
      end

      CheckRegistry.instance.register(:constant, Constant)
    end
  end
end
