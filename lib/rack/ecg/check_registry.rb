# frozen_string_literal: true

require "singleton"

module Rack
  class ECG
    class CheckRegistry
      # Raised when a check didn't exist during lookup
      CheckNotRegistered = Class.new(StandardError)
      include Singleton

      # Constructs the singleton instance of the registry
      def initialize
        @registry = {}
      end

      # Register a check class by name
      #
      # @param [Symbol] name Desired check name
      # @param [Class] check_class Class implementing check functionality
      def register(name, check_class)
        @registry[name] = check_class
      end

      # Fetches the registered check class by name
      #
      # @param [Symbol] name Registered check name
      # @raise [CheckNotRegistered] if the named check has not been registered
      def lookup(name)
        @registry.fetch(name) { raise CheckNotRegistered, "Check '#{name}' is not registered" }
      end

      # (see #lookup)
      def self.lookup(name)
        instance.lookup(name)
      end

      # (see #register)
      def self.register(name, check_class)
        instance.register(name, check_class)
      end
    end
  end
end
