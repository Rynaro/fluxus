# frozen_string_literal: true

require 'test_helper'

module Fluxus
  class RunnerTest < Minitest::Test
    def test_runner_is_abstract_class
      assert_raises(::Fluxus::Runner::CallerNotImplemented, 'the flow must be implemented by a caller') do
        Runner.call!
      end
    end

    def test_runner_direct_instances_are_not_allowed
      assert_raises(NoMethodError) { Runner.new }
    end
  end
end
