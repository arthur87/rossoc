# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Ir
  class Ir
    def initialize(in_pins, out_pins, where, ast, sleep_sec)
      @in_pins = in_pins
      @out_pins = out_pins
      @where = where
      @ast = ast
      @sleep_sec = sleep_sec
    end

    def result
      din_pins = Set.new
      ain_pins = Set.new
      dout_pins = Set.new
      aout_pins = Set.new

      @in_pins.each do |pin|
        n = pin.gsub(/din|ain/, '').to_i
        if pin.start_with?('din')
          din_pins.add(n)
        else
          ain_pins.add(n)
        end
      end

      @out_pins.each do |pin|
        n = pin.gsub(/din|ain/, '').to_i
        if pin.start_with?('din')
          dout_pins.add(n)
        else
          aout_pins.add(n)
        end
      end

      {
        din_pins: din_pins,
        ain_pins: ain_pins,
        dout_pins: dout_pins,
        aout_pins: aout_pins,
        where: @where,
        ast: @ast,
        sleep_sec: @sleep_sec
      }
    end
  end
end
