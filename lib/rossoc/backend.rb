# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Backend
  class Backend
    class BackendError < StandardError; end

    RESERVED_TABLES = %w[mruby arduino].freeze

    def initialize(ir, output)
      @ir = ir
      @output = output
    end

    def execute
      table = @ir[:table]
      raise BackendError, "unknown table value #{table}" if RESERVED_TABLES.index(table).nil?

      template = ERB.new(
        File.read("#{__dir__}#{File::SEPARATOR}views#{File::SEPARATOR}#{table}.erb"),
        trim_mode: 2
      )
      content = template.result_with_hash(@ir)

      raise BackendError, 'No output file' if @output.blank?

      file = File.open(@output, 'w')
      file.write(content)
      file.close
    end
  end
end
