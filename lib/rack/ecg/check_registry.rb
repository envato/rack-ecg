require "singleton"

module Rack
  class ECG
    class CheckRegistry
      include Singleton

      def initialize()
        @registry = {}
      end

      def register(name, check_class)
        @registry[name] = check_class
      end

      def [](name)
        @registry[name]
      end
    end
  end
end
