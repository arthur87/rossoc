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
    method_option :output, desc: 'Output', aliases: '-o'
    method_option :sleep, desc: 'Sleep'
    def query
      client = Rossoc::Query.new(options[:input].to_s, options[:output].to_s, options[:sleep].to_i)
      client.execute
    end
  end
end
