# frozen_string_literal: true

require 'fluxus/results/result'

module Fluxus
  module Results
    class Failure < Result
      private

      def define_state
        :failure
      end
    end
  end
end
