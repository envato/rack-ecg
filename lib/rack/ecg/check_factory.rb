require "rack/ecg/check"

module Rack
  class ECG
    class CheckFactory
      CheckDefinition = Struct.new(:check_class, :parameters)

      def initialize(definitions, default_checks: [])
        definitions = Array(definitions) | default_checks

        @checks = definitions.map do |check_name, check_parameters|
          CheckDefinition.new(CheckRegistry.lookup(check_name), check_parameters)
        end
      end

      def build_all
        @checks.map do |check_definition|
          build(check_class: check_definition.check_class, parameters: check_definition.parameters)
        end
      end

      def build(check_class:, parameters: nil)
        parameters.nil? ? check_class.new : check_class.new(parameters)
      end
    end
  end
end
