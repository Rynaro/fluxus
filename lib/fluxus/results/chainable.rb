# frozen_string_literal: true

module Fluxus
  module Results
    module Chainable
      def then(klass, **kwargs)
        return self if failure?

        data ||= {}
        klass.call!(**data.merge(kwargs))
      end

      def on_success(expected_type = nil)
        yield(data) if __success_type?(expected_type)
        self
      end

      def on_failure(expected_type = nil)
        yield(data) if __failure_type?(expected_type)
        self
      end

      def on_exception(expected_exception = nil)
        return self unless __failure_type?(:exception)

        if expected_exception.nil? ||
           (expected_exception.is_a?(Exception) && data[:exception].is_a?(expected_exception))
          yield(data)
        end
        self
      end

      def __success_type?(expected_type)
        success? && (expected_type.nil? || expected_type == type)
      end

      def __failure_type?(expected_type = nil)
        failure? && (expected_type.nil? || expected_type == type)
      end
    end
  end
end
