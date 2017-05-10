require "singleton"

module Rack
  class ECG
    class CheckRegistry
      CheckNotRegistered = Class.new(StandardError)
      include Singleton

      def initialize()
        @registry = {}
      end

      def register(name, check_class)
        @registry[name] = check_class
      end

      def lookup(name)
        @registry.fetch(name) { raise CheckNotRegistered.new("Check '#{name}' is not registered") }
      end

      def self.lookup(name)
        instance.lookup(name)
      end

      def self.register(name, check_class)
        instance.register(name, check_class)
      end
    end
  end
end
