# frozen_string_literal: true

module Fluxus
  require 'fluxus/results/success'
  require 'fluxus/results/failure'

  class Runner
    class ResultTypeNotDefinedError < StandardError; end
    class CallerNotImplemented < StandardError; end

    private_class_method :new

    def self.call!(...)
      raise CallerNotImplemented, 'the flow must be implemented by a caller'
    end

    def self.__call__(instance, ...)
      result = instance.call!(...)
      raise ResultTypeNotDefinedError, 'flow results must be Success or Failure' unless result.is_a?(Results::Result)

      result
    end
    private_class_method :__call__

    def call!
      raise NotImplementedError, '#call! must be implemented'
    end

    # rubocop:disable Naming/MethodName
    def Success(type: :ok, result: nil)
      @__result = Results::Success.new(type: type, data: result)
    end

    def Failure(type: :error, result: nil)
      @__result = Results::Failure.new(type: type, data: result)
    end
    # rubocop:enable Naming/MethodName

    private

    attr_reader :__result
  end
end
