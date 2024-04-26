# frozen_string_literal: true

require 'rossoc'

module Rossoc
  # query
  class Query
    FIELDS = %w[
      din0 din1 din2 din3 din4 din5 din6 din7 din8 din9 din10
      din11 din12 din13 din14 din15 din16 din17 din18 din19 din20
    ].freeze

    def initialize; end

    def parser(sql)
      # sql = 'select din11 from board where din1=1 and 2=din2 or din3 >2'

      parser = SQLParser::Parser.new
      ast = parser.scan_str(sql)

      @sql = ast.to_sql
      @columns = ast.query_expression.list.columns
      @tables = ast.query_expression.table_expression.from_clause.tables

      @condition = if ast.query_expression.table_expression.where_clause.nil?
                     nil
                   else
                     ast.query_expression.table_expression.where_clause.search_condition
                   end
    rescue StandardError => e
      warn "Syntax error: #{e}"
      exit(1)
    end

    def generator
      @all_pins = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      @out_pins = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

      @columns.each do |column|
        name = column.name
        index = FIELDS.index(name)
        if index.nil?
          warn "Unknown column: #{name}"
          exit(1)
        else
          @all_pins[index] = 1
          @out_pins[index] = 1
        end
      end

      @tables.each do |table|
        name = table.name
        if name != 'board'
          warn "Unknown table: #{name}"
          exit(1)
        end
      end

      if @condition.nil?
        @where = 1
      else
        tree_trace(@condition)
        @where = rewrite_condition(@condition.to_sql)
      end

      template = ERB.new(File.read("#{__dir__}#{File::SEPARATOR}ruby.erb"))
      puts template.result_with_hash({ all_pins: @all_pins, out_pins: @out_pins, where: @where, sql: @sql })
    end

    private

    def tree_trace(condition)
      root_words = ['SQLParser::Statement::Equals',
                    'SQLParser::Statement::Greater',
                    'SQLParser::Statement::GreaterOrEquals',
                    'SQLParser::Statement::Less',
                    'SQLParser::Statement::LessOrEquals',
                    'SQLParser::Statement::And',
                    'SQLParser::Statement::Or']
      not_words = ['SQLParser::Statement::Not']
      value_words = ['SQLParser::Statement::Float', 'SQLParser::Statement::Integer']
      column_words = ['SQLParser::Statement::Column']

      if root_words.include?(condition.class.to_s)
        tree_trace(condition.left)
        tree_trace(condition.right)
      elsif not_words.include?(condition.class.to_s)
        tree_trace(condition.value.left)
        tree_trace(condition.value.right)
      elsif column_words.include?(condition.class.to_s)
        name = condition.name
        index = FIELDS.index(name)
        if index.nil?
          warn "Unknown column: #{name}"
          exit(1)
        else
          @all_pins[index] = 1
        end
      elsif value_words.include?(condition.class.to_s)
        # none
      else
        warn "Unknown token: #{condition}"
        exit(1)
      end
    end

    def rewrite_condition(condition)
      tokens = condition.split(' ')
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

      tokens.join(' ')
    end
  end
end
