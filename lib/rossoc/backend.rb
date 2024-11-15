# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Backend
  class Backend
    class BackendError < StandardError; end

    RESERVED_TABLES = %w[mruby arduino dev].freeze

    def initialize(ir, output, overwrite_enable)
      @ir = ir
      @output = output
      @content = nil
      @overwrite_enable = overwrite_enable
    end

    def generate
      table = @ir[:table]
      raise BackendError, "unknown table value #{table}." if RESERVED_TABLES.index(table).nil?

      template = ERB.new(
        File.read("#{__dir__}#{File::SEPARATOR}views#{File::SEPARATOR}#{table}.erb"),
        trim_mode: 2
      )

      @content = template.result_with_hash(@ir)
    end

    def write
      raise BackendError, 'No content.' if @content.nil?

      raise BackendError, 'No output file.' if @output.blank?

      raise BackendError, "File exists #{@output}." if File.exist?(@output) && !@overwrite_enable

      file = File.open(@output, 'w')
      file.write(@content)
      file.close
    end
  end
end
