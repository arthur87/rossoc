# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Backend
  class Backend
    def initialize(ir, output)
      @ir = ir
      @output = output
    end

    def execute
      template = ERB.new(File.read("#{__dir__}#{File::SEPARATOR}views#{File::SEPARATOR}ruby.erb"))
      content = template.result_with_hash({ all_pins: @ir.all_pins, out_pins: @ir.out_pins, where: @ir.where,
                                            sleep_sec: @ir.sleep_sec })

      if @output.blank?
        warn 'No output file'
        exit(1)
      end
      file = File.open(@output, 'w')
      file.write(content)
      file.close
    end
  end
end
