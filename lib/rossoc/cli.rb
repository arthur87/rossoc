# frozen_string_literal: true

require 'rossoc'
require 'thor'

module Rossoc
  # entry point
  class CLI < Thor
    class << self
      def exit_on_failure?
        true
      end
    end

    desc 'version', 'Show Version'
    def version
      puts(Rossoc::VERSION)
    end

    desc 'query', 'Query'
    method_option :input, desc: 'Input', aliases: '-i'
    def query
      client = Rossoc::Query.new
      client.parser(options[:input].to_s)
      client.generator
    end
  end
end
