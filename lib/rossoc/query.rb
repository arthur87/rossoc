# frozen_string_literal: true

require 'rossoc'

# Rossoc
module Rossoc
  # query
  class Query
    FIELDS = %w[
      din0 din1 din2 din3 din4 din5 din6 din7 din8 din9 din10
      din11 din12 din13 din14 din15 din16 din17 din18 din19 din20
    ].freeze

    def initialize(input, output, sleep_sec)
      @input = input
      @output = output
      @sleep_sec = sleep_sec
      @all_pins = Set.new
      @out_pins = Set.new
    end

    def execute
      parser(@input)
      check_columns
      check_tables
      check_condition
      content = generator(@all_pins, @out_pins, @where, @ast.to_sql, @sleep_sec)
      file_writer(content, @output)
    end

    private

    def parser(sql)
      parser = SQLParser::Parser.new
      @ast = parser.scan_str(sql)
    rescue StandardError => e
      warn "Syntax error: #{e}"
      exit(1)
    end

    def check_columns
      columns = @ast.query_expression.list.columns
      columns.each do |column|
        name = column.name
        index = FIELDS.index(name)
        if index.nil?
          warn "Unknown column: #{name}"
          exit(1)
        else
          @all_pins.add(index)
          @out_pins.add(index)
        end
      end
    rescue StandardError => e
      warn "Syntax error: #{e}"
      exit(1)
    end

    def check_tables
      tables = @ast.query_expression.table_expression.from_clause.tables
      tables.each do |table|
        name = table.name
        if name != 'board'
          warn "Unknown table: #{name}"
          exit(1)
        end
      end
    rescue StandardError => e
      warn "Syntax error: #{e}"
      exit(1)
    end

    def check_condition
      begin
        condition = if @ast.query_expression.table_expression.where_clause.nil?
                      nil
                    else
                      @ast.query_expression.table_expression.where_clause.search_condition
                    end
      rescue StandardError => e
        warn "Syntax error: #{e}"
        exit(1)
      end

      if !condition.nil?
        tree_trace(condition)

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

    def tree_trace(condition)
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
          @all_pins.add(index)
        end
      elsif value_words.include?(condition.class.to_s)
        # none
      else
        warn "Unknown token: #{condition}"
        exit(1)
      end
    end

    def generator(all_pins, out_pins, where, sql, sleep_sec)
      template = ERB.new(File.read("#{__dir__}#{File::SEPARATOR}ruby.erb"))
      template.result_with_hash({ all_pins: all_pins, out_pins: out_pins, where: where, sql: sql,
                                  sleep_sec: sleep_sec })
    end

    def file_writer(content, output)
      if output.blank?
        warn 'No output file'
        exit(1)
      end
      file = File.open(output, 'w')
      file.write(content)
      file.close
    end
  end
end
