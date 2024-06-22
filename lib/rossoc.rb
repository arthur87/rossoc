# frozen_string_literal: true

require_relative 'rossoc/version'
require 'strscan'
require 'date'
require 'racc/parser'
require_relative 'rossoc/statement'
require_relative 'rossoc/sql_visitor'
require_relative 'rossoc/parser.racc'
require 'rossoc/cli'
require 'rossoc/frontend'
require 'rossoc/backend'
require 'rossoc/ir'
require 'active_support/all'
require 'erb'
require 'set'

module Rossoc
  class Error < StandardError; end
  # Your code goes here...
end
