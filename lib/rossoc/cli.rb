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
    def query
      frontend = Rossoc::Frontend.new(options[:input].to_s)
      begin
        ir = frontend.ir
      rescue Racc::ParseError => e
        warn e.message
        exit(1)
      rescue Rossoc::Frontend::FrontendError => e
        warn e.message
        exit(1)
      rescue StandardError => e
        warn e.message
        exit(1)
      end

      begin
        backend = Rossoc::Backend.new(ir, options[:output].to_s)
        backend.execute
      rescue Rossoc::Backend::BackendError => e
        warn e.message
        exit(1)
      rescue StandardError => e
        warn e.message
        exit(1)
      end
    end
  end
end
