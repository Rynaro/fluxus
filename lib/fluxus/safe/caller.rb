# frozen_string_literal: true

require 'fluxus/runner'

module Fluxus
  module Safe
    class Caller < Runner
      def self.call!(...)
        instance = new
        __call__(instance, ...)
      rescue StandardError => e
        raise e if e.is_a?(ResultTypeNotDefinedError)

        instance.Failure(type: :exception, result: { exception: e })
      end
    end
  end
end
