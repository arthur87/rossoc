# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Backend
  class Backend
    class BackendError < StandardError; end

    def initialize(ir, output)
      @ir = ir
      @output = output
    end

    def execute
      template = ERB.new(File.read("#{__dir__}#{File::SEPARATOR}views#{File::SEPARATOR}mruby.erb"))
      content = template.result_with_hash(@ir.result)

      raise BackendError, 'No output file' if @output.blank?

      file = File.open(@output, 'w')
      file.write(content)
      file.close
    end
  end
end
