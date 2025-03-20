# frozen_string_literal: true

require 'test_helper'

module Fluxus
  module Results
    class ChainableTest < Minitest::Test
      # Simple use case that returns a hash
      class HashReturningCase < ::Fluxus::Caller
        def call!(name:, **kwargs)
          Success(result: { full_name: name, **kwargs })
        end
      end

      # Simple use case that returns a string (non-hash)
      class StringReturningCase < ::Fluxus::Caller
        def call!(name:, **kwargs)
          Success(result: "Hello, #{name}!")
        end
      end

      # A use case to test the chain that expects hash input
      class ExpectsHashCase < ::Fluxus::Caller
        def call!(full_name:, **kwargs)
          Success(result: { user: full_name, processed: true, **kwargs })
        end
      end

      # A use case to test the chain that expects string input
      class ExpectsResultCase < ::Fluxus::Caller
        def call!(result:, **kwargs)
          Success(result: "#{result} (Processed)")
        end
      end

      def test_then_with_hash_data
        # Chain with hash data
        result = HashReturningCase
                 .call!(name: 'John Doe')
                 .then(ExpectsHashCase)

        assert_equal true, result.success?
        assert_equal 'John Doe', result.data[:user]
        assert_equal true, result.data[:processed]
      end

      def test_then_with_non_hash_data
        # Chain with string data, should be wrapped as { result: "..." }
        result = StringReturningCase
                 .call!(name: 'Jane Doe')
                 .then(ExpectsResultCase)

        assert_equal true, result.success?
        assert_equal 'Hello, Jane Doe! (Processed)', result.data
      end

      def test_then_with_additional_kwargs
        # Chain with hash data and additional kwargs
        result = HashReturningCase
                 .call!(name: 'John Doe')
                 .then(ExpectsHashCase, extra: 'parameter')

        assert_equal true, result.success?
        assert_equal 'John Doe', result.data[:user]
        assert_equal 'parameter', result.data[:extra]
      end

      def test_then_with_non_hash_and_kwargs
        result = StringReturningCase
                 .call!(name: 'Jane Doe')
                 .then(ExpectsResultCase, priority: 'high')

        assert_equal true, result.success?
        assert_equal 'Hello, Jane Doe! (Processed)', result.data
      end

      def test_then_not_called_on_failure
        failure = Failure.new(data: 'Failed operation')
        result = failure.then(ExpectsResultCase)

        assert_equal true, result.failure?
        assert_equal 'Failed operation', result.data
      end
    end
  end
end
