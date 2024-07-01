# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # Frontend
  class Frontend
    class FrontendError < StandardError; end

    FIELDS = %w[
      din0 din1 din2 din3 din4 din5 din6 din7 din8 din9 din10
      din11 din12 din13 din14 din15 din16 din17 din18 din19 din20
    ].freeze

    def initialize(input)
      @input = input
      @all_pins = Set.new
      @out_pins = Set.new
      @where = nil
      @ast = nil
      @sleep_sec = 0
    end

    def ir
      parser(@input)
      check_columns
      check_tables
      check_condition

      Rossoc::Ir.new(@all_pins, @out_pins, @where, @ast, @sleep_sec)
    end

    private

    def parser(sql)
      parser = SQLParser::Parser.new
      @ast = parser.scan_str(sql)
    rescue Racc::ParseError => e
      raise e
    end

    def check_columns
      columns = @ast.query_expression.list.columns
      columns.each do |column|
        name = column.name
        index = FIELDS.index(name)
        raise FrontendError, "unknown column value #{name}" if index.nil?

        @all_pins.add(index)
        @out_pins.add(index)
      end
    rescue StandardError => e
      raise e
    end

    def check_tables
      tables = @ast.query_expression.table_expression.from_clause.tables
      tables.each do |table|
        name = table.name
        raise FrontendError, "unknown table value #{name}" if name != 'board'
      end
    rescue StandardError => e
      raise e
    end

    def check_condition
      begin
        condition = if @ast.query_expression.table_expression.where_clause.nil?
                      nil
                    else
                      @ast.query_expression.table_expression.where_clause.search_condition
                    end
      rescue StandardError => e
        raise e
      end

      if !condition.nil?
        condition_parser(condition)

        tokens = condition.to_sql.split(' ')
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
      else
        @where = 1
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
        index = FIELDS.index(name)
        raise FrontendError, "unknown column value #{name}" if index.nil?

        @all_pins.add(index)

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
  end
end
