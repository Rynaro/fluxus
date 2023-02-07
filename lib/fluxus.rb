# frozen_string_literal: true

require 'fluxus/version'
require 'fluxus/caller'
require 'fluxus/safe/caller'

module Fluxus
  Object = Caller
  SafeObject = Safe::Caller
end
