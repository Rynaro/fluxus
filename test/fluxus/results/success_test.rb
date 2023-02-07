# frozen_string_literal: true

require 'test_helper'

module Fluxus
  module Results
    class SuccessTest < Minitest::Test
      def test_default_instance_creation
        result = Success.new

        assert_equal :unknown, result.type
        assert_equal ({}), result.data
      end

      def test_type_definition
        result = Success.new(type: :persisted)

        assert_equal :persisted, result.type
      end

      def test_data_definition
        expected_data = { record_id: 1 }
        result = Success.new(data: expected_data)

        assert_equal expected_data, result.data
      end

      def test_success_must_be_truth
        result = Success.new

        assert result.success?
      end

      def test_failure_must_be_false
        result = Success.new

        refute result.failure?
      end

      def test_unknown_must_be_false
        result = Success.new

        refute result.unknown?
      end

      def test_result_implement_chainable_public_contract
        result = Success.new

        assert result.respond_to?(:on_success)
        assert result.respond_to?(:on_failure)
        assert result.respond_to?(:on_exception)
      end

      def test_data_must_be_immutable_over_chainable_scope
        result = Success.new(type: :calculated, data: { sum: 2 })

        result.on_success { |data| assert_equal 4, data[:sum] * 2 }
        assert_equal 2, result.data[:sum]
      end

      def test_on_success_chainable_broader_scope
        result = Success.new(type: :calculated, data: { sum: 2 })

        result.on_success { |data| assert_equal 2, data[:sum] }
      end

      def test_on_success_multiple_chains_with_scoped_return
        result = Success.new(type: :calculated, data: { sum: 2 })

        result
          .on_success(:skipped) { raise }
          .on_success(:calculated) { |data| assert_equal 2, data[:sum] }
      end

      def test_on_failure_skipped_by_caller
        result = Success.new(type: :calculated, data: { sum: 2 })

        result.on_failure { raise }
      end

      def test_chainable_methods_preserves_self
        result = Success.new(type: :calculated, data: { sum: 2 })

        assert_equal Success, result.on_success {}.class
        assert_equal Success, result.on_failure {}.class
        assert_equal Success, result.on_exception {}.class
      end

      def test_assertive_chainable_scope_runtime
        result = Success.new(type: :calculated, data: { sum: 2 })

        result
          .on_failure { raise }
          .on_success(:skipped) { raise }
          .on_success(:calculated) { |data| assert_equal 2, data[:sum] }
      end
    end
  end
end
