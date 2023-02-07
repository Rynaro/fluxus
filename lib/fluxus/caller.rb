# frozen_string_literal: true

require 'fluxus/runner'

module Fluxus
  class Caller < Runner
    def self.call!(...)
      __call__(new, ...)
    end
  end
end
