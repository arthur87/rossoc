# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Ir
  class Ir
    def initialize(all_pins, out_pins, where, ast, sleep_sec)
      @all_pins = all_pins
      @out_pins = out_pins
      @where = where
      @ast = ast
      @sleep_sec = sleep_sec
    end

    attr_reader :all_pins, :out_pins, :where, :sleep_sec

    def result
      {
        all_pins: @all_pins,
        out_pins: @out_pins,
        where: @where,
        ast: @ast,
        sleep_sec: @sleep_sec
      }
    end
  end
end
