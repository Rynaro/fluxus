# frozen_string_literal: true

require 'test_helper'

module Fluxus
  module Results
    class FailureTest < Minitest::Test
      class ReallySpecificError < StandardError; end

      def test_default_instance_creation
        result = Failure.new

        assert_equal :unknown, result.type
        assert_equal ({}), result.data
      end

      def test_type_definition
        result = Failure.new(type: :persisted)

        assert_equal :persisted, result.type
      end

      def test_data_definition
        expected_data = { record_id: 1 }
        result = Failure.new(data: expected_data)

        assert_equal expected_data, result.data
      end

      def test_success_must_be_false
        result = Failure.new

        refute result.success?
      end

      def test_failure_must_be_true
        result = Failure.new

        assert result.failure?
      end

      def test_unknown_must_be_false
        result = Failure.new

        refute result.unknown?
      end

      def test_result_implement_chainable_public_contract
        result = Failure.new

        assert result.respond_to?(:on_success)
        assert result.respond_to?(:on_failure)
        assert result.respond_to?(:on_exception)
      end

      def test_data_must_be_immutable_over_chainable_scope
        result = Failure.new(type: :miscalculated, data: { sum: 3 })

        result.on_success { |data| assert_equal 6, data[:sum] * 3 }
        assert_equal 3, result.data[:sum]
      end

      def test_on_failure_chainable_broader_scope
        result = Failure.new(type: :miscalculated, data: { sum: -1 })

        result.on_failure { |data| assert_equal(-1, data[:sum]) }
      end

      def test_on_success_multiple_chains_with_scoped_return
        result = Failure.new(type: :miscalculated, data: { sum: 2 })

        result
          .on_failure(:skipped) { raise }
          .on_failure(:miscalculated) { |data| assert_equal 2, data[:sum] }
      end

      def test_on_success_skipped_by_caller
        result = Failure.new(type: :miscalculated, data: { sum: 2 })

        result.on_success { raise }
      end

      def test_chainable_methods_preserves_self
        result = Failure.new(type: :miscalculated, data: { sum: 2 })

        assert_equal Failure, result.on_success {}.class
        assert_equal Failure, result.on_failure {}.class
        assert_equal Failure, result.on_exception {}.class
      end

      def test_assertive_chainable_scope_runtime
        result = Failure.new(type: :miscalculated, data: { sum: 2 })

        result
          .on_success(:skipped) { raise }
          .on_success(:calculated) { raise }
          .on_failure { |data| assert 2, data[:sum] }
      end

      def test_on_exception_error_caught
        result = Failure.new(type: :exception, data: StandardError.new('i failed :('))

        result
          .on_failure(:miscalculated) { raise }
          .on_exception { |data| assert_equal 'i failed :(', data.message }
      end

      def test_on_exception_scoped_caught
        result = Failure.new(type: :exception, data: ReallySpecificError.new('i failed :('))

        result
          .on_failure(:miscalculated) { raise }
          .on_exception(ReallySpecificError) { |data| assert_equal 'i failed :(', data.message }
      end
    end
  end
end
