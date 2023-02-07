# frozen_string_literal: true

module Fluxus
  module Results
    require 'fluxus/results/chainable'

    class Result
      include Chainable
      attr_reader :type, :data

      class StateNotImplemented < StandardError; end

      def initialize(type: :unknown, data: {})
        @type = type
        @data = data
        @state = define_state
      end

      def success?
        state == :success
      end

      def failure?
        state == :failure
      end

      def unknown?
        !(failure? || success?)
      end

      private

      attr_reader :state

      def define_state
        raise StateNotImplemented, 'the #define_state hook must be implemented by a concrete class'
      end
    end
  end
end
