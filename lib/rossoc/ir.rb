# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Ir
  class Ir
    # rubocop:disable Metrics/ParameterLists
    def initialize(in_pins, out_pins, table, where, ast,
                   sleep_sec, speed)
      @in_pins = in_pins
      @out_pins = out_pins
      @table = table
      @where = where
      @ast = ast
      @sleep = Rsleep.new(sleep_sec)
      @speed = speed
    end
    # rubocop:enable Metrics/ParameterLists

    # rubocop:disable Metrics/MethodLength
    def result
      din_pins = Set.new
      ain_pins = Set.new
      dout_pins = Set.new
      aout_pins = Set.new

      [@in_pins, @out_pins].each_with_index do |pins, i|
        pins.each do |pin|
          n = pin.gsub(/din|ain/, '').to_i
          if pin.start_with?('din')
            if i.zero?
              din_pins.add(n)
            else
              dout_pins.add(n)
            end
          elsif i.zero?
            ain_pins.add(n)
          else
            aout_pins.add(n)
          end
        end
      end

      {
        din_pins: din_pins,
        ain_pins: ain_pins,
        dout_pins: dout_pins,
        aout_pins: aout_pins,
        table: @table,
        where: @where,
        ast: @ast,
        sleep: @sleep,
        speed: @speed
      }
    end
    # rubocop:enable Metrics/MethodLength

    # RSLEEP
    class Rsleep
      def initialize(second)
        @second = second
      end

      def positive?
        @second.positive?
      end

      attr_reader :second

      def millisecond
        (@second * 1000).to_i
      end
    end
  end
end
