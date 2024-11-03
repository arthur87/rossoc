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
    method_option :input, desc: 'Input query', aliases: '-i'
    method_option :output, desc: 'Write output to <file>', aliases: '-o'
    method_option :ir, desc: 'Show IR Information', type: :boolean, default: false
    method_option :yes, desc: 'Overwrite output file', type: :boolean, default: false, aliases: '-y'
    def query
      frontend = Rossoc::Frontend.new(options[:input].to_s)
      begin
        ir = frontend.ir
      rescue StandardError => e
        warn e.message
        exit(1)
      end

      pp ir if options[:ir]

      begin
        backend = Rossoc::Backend.new(ir, options[:output].to_s, options[:yes])
        backend.generate
        backend.write
      rescue StandardError => e
        warn e.message
        exit(1)
      end
    end
  end
end
