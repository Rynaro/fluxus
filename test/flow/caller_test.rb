# frozen_string_literal: true

require 'test_helper'

module Fluxus
  class CallerTest < Minitest::Test
    class CheckEven < ::Fluxus::Caller
      def call!(number:)
        return false if number.is_a?(String)
        return Failure(type: :odd, result: "#{number} is odd") if number.odd?

        Success(type: :even, result: "#{number} is even")
      end
    end

    class NoFluxus < ::Fluxus::Caller; end

    def test_caller_runtime_must_not_accept_explicit_instantiation
      assert_raises(NoMethodError) { CheckEven.new }
    end

    def test_caller_definition_passthrough_runner_as_pipeline
      CheckEven
        .call!(number: 2)
        .on_success { |data| assert_equal '2 is even', data }
        .on_failure { raise }
    end

    def test_errors_should_be_exposed_from_caller
      assert_raises(NoMethodError, "undefined method `odd?' for nil:NilClass") do
        CheckEven.call!(number: nil)
      end
    end

    def test_thrown_error_for_not_implemented_callers
      assert_raises(NotImplementedError, 'the flow must be implemented by a caller') do
        NoFluxus.call!
      end
    end

    def test_caller_must_return_result_interfaces
      assert_raises(::Fluxus::Runner::ResultTypeNotDefinedError, 'flow results must be Success or Failure') do
        CheckEven.call!(number: 'ten')
      end
    end
  end
end
