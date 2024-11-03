# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Frontend
  # rubocop:disable Metrics/ClassLength
  class Frontend
    class FrontendError < StandardError; end

    RESERVED_PINS = %w[
      din0 din1 din2 din3 din4 din5 din6 din7 din8 din9 din10
      din11 din12 din13 din14 din15 din16 din17 din18 din19 din20
      ain0 ain1 ain2 ain3 ain4 ain5 ain6 ain7 ain8 ain9 ain10
      ain11 ain12 ain13 ain14 ain15 ain16 ain17 ain18 ain19 ain20
    ].freeze

    def initialize(input)
      @input = input
      @out_pins = Set.new
      @in_pins = Set.new
      @table = nil
      @where = nil
      @ast = nil
      @sleep_sec = 0
      @speed = 9600
    end

    def ir
      parser(@input)
      check_columns
      check_tables
      check_condition
      check_rsleep
      check_rspeed

      Rossoc::Ir.new(@in_pins, @out_pins, @table, @where, @ast,
                     @sleep_sec, @speed).result
    end

    private

    def parser(sql)
      parser = SQLParser::Parser.new
      @ast = parser.scan_str(sql)
    rescue Racc::ParseError => e
      raise FrontendError, e
    end

    def check_columns
      columns = @ast.query_expression.list.columns
      columns.each do |column|
        name = column.name
        index = RESERVED_PINS.index(name)
        raise FrontendError, "unknown column value #{name}" if index.nil?

        @in_pins.add(name)
        @out_pins.add(name)
      end
    rescue e
      raise e
    end

    def check_tables
      tables = @ast.query_expression.table_expression.from_clause.tables
      tables.each do |table|
        @table = table.name
      end
    rescue e
      raise e
    end

    def check_condition
      begin
        condition = if @ast.query_expression.table_expression.where_clause.nil?
                      nil
                    else
                      @ast.query_expression.table_expression.where_clause.search_condition
                    end
      rescue e
        raise e
      end

      if condition.nil?
        @where = 1
      else
        condition_parser(condition)

        tokens = condition.to_sql.split
        tokens.each_with_index do |token, index|
          case token
          when '='
            token = '=='
          when 'AND'
            token = '&&'
          when 'OR'
            token = '||'
          when '<>'
            token = '!='
          end
          tokens[index] = token.gsub('`', '')
        end

        @where = tokens.join(' ')
      end
    end

    def condition_parser(condition)
      root_words = ['SQLParser::Statement::Equals',
                    'SQLParser::Statement::Greater',
                    'SQLParser::Statement::GreaterOrEquals',
                    'SQLParser::Statement::Less',
                    'SQLParser::Statement::LessOrEquals',
                    'SQLParser::Statement::And',
                    'SQLParser::Statement::Or']
      not_words = ['SQLParser::Statement::Not']
      value_words = ['SQLParser::Statement::Float',
                     'SQLParser::Statement::Integer']
      column_words = ['SQLParser::Statement::Column']

      if root_words.include?(condition.class.to_s)
        condition_parser(condition.left)
        condition_parser(condition.right)
      elsif not_words.include?(condition.class.to_s)
        condition_parser(condition.value.left)
        condition_parser(condition.value.right)
      elsif column_words.include?(condition.class.to_s)
        name = condition.name
        index = RESERVED_PINS.index(name)
        raise FrontendError, "unknown column value #{name}" if index.nil?

        @in_pins.add(name)
      elsif value_words.include?(condition.class.to_s)
        # none
      else
        raise FrontendError, "unknown token value #{condition}"
      end
    end

    def check_rsleep
      return if @ast.rsleep.nil?

      @sleep_sec = @ast.rsleep.rsleep_specification.value
    end

    def check_rspeed
      return if @ast.rspeed.nil?

      @speed = @ast.rspeed.rspeed_specification.value
    end
  end
  # rubocop:enable Metrics/ClassLength
end
