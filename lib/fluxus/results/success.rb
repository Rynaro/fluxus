# frozen_string_literal: true

require 'fluxus/results/result'

module Fluxus
  module Results
    class Success < Result
      private

      def define_state
        :success
      end
    end
  end
end
