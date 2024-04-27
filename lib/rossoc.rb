# frozen_string_literal: true

require_relative 'rossoc/version'
require 'rossoc/cli'
require 'rossoc/query'
require 'active_support/all'
require 'erb'
require 'sql-parser'
require 'set'

module Rossoc
  class Error < StandardError; end
  # Your code goes here...
end
