# frozen_string_literal: true

require 'test_helper'

module Fluxus
  module Results
    class ResultTest < Minitest::Test
      def test_result_is_not_instantiable
        assert_raises(
          Result::StateNotImplemented,
          'the #define_state hook must be implemented by a concrete class'
        ) do
          Result.new(type: :ok, data: 'created')
        end
      end
    end
  end
end
