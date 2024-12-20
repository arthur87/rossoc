# frozen_string_literal: true
#
# Original source code
# sql-parser
# https://github.com/cryodex/sql-parser
#

module SQLParser
  module Statement
    class Node
      def accept(visitor)
        klass = self.class.ancestors.find do |ancestor|
          visitor.respond_to?("visit_#{demodulize(ancestor.name)}")
        end

        raise "No visitor for #{self.class.name}" unless klass

        visitor.__send__("visit_#{demodulize(klass.name)}", self)
      end

      def to_sql
        SQLVisitor.new.visit(self)
      end

      private

      def demodulize(str)
        str.split('::')[-1]
      end
    end

    class Insert < Node
      def initialize(table_reference, column_list, in_value_list)
        @table_reference = table_reference
        @column_list = column_list
        @in_value_list = in_value_list
      end

      attr_reader :table_reference, :column_list, :in_value_list
    end

    class DirectSelect < Node
      def initialize(query_expression, order_by, rsleep = nil, rspeed = nil)
        @query_expression = query_expression
        @order_by = order_by
        @rsleep = rsleep
        @rspeed = rspeed
      end

      attr_reader :query_expression, :order_by, :rsleep, :rspeed
    end

    class OrderBy < Node
      def initialize(sort_specification)
        @sort_specification = Array(sort_specification)
      end

      attr_reader :sort_specification
    end

    class Rsleep < Node
      def initialize(rsleep_specification)
        @rsleep_specification = rsleep_specification
      end

      attr_reader :rsleep_specification
    end

    class Rspeed < Node
      def initialize(rspeed_specification)
        @rspeed_specification = rspeed_specification
      end

      attr_reader :rspeed_specification
    end

    class Subquery < Node
      def initialize(query_specification)
        @query_specification = query_specification
      end

      attr_reader :query_specification
    end

    class Select < Node
      def initialize(list, table_expression = nil)
        @list = list
        @table_expression = table_expression
      end

      attr_reader :list, :table_expression
    end

    class SelectList < Node
      def initialize(columns)
        @columns = Array(columns)
      end

      attr_reader :columns
    end

    class Distinct < Node
      def initialize(column)
        @column = column
      end

      attr_reader :column
    end

    class All < Node
    end

    class TableExpression < Node
      def initialize(from_clause, where_clause = nil, group_by_clause = nil, having_clause = nil)
        @from_clause = from_clause
        @where_clause = where_clause
        @group_by_clause = group_by_clause
        @having_clause = having_clause
      end

      attr_reader :from_clause, :where_clause, :group_by_clause, :having_clause
    end

    class FromClause < Node
      def initialize(tables)
        @tables = Array(tables)
      end

      attr_reader :tables
    end

    class OrderClause < Node
      def initialize(columns)
        @columns = Array(columns)
      end

      attr_reader :columns
    end

    class OrderSpecification < Node
      def initialize(column)
        @column = column
      end

      attr_reader :column
    end

    class Ascending < OrderSpecification
    end

    class Descending < OrderSpecification
    end

    class HavingClause < Node
      def initialize(search_condition)
        @search_condition = search_condition
      end

      attr_reader :search_condition
    end

    class GroupByClause < Node
      def initialize(columns)
        @columns = Array(columns)
      end

      attr_reader :columns
    end

    class WhereClause < Node
      def initialize(search_condition)
        @search_condition = search_condition
      end

      attr_reader :search_condition
    end

    class On < Node
      def initialize(search_condition)
        @search_condition = search_condition
      end

      attr_reader :search_condition
    end

    class SearchCondition < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_reader :left, :right
    end

    class Using < Node
      def initialize(columns)
        @columns = Array(columns)
      end

      attr_reader :columns
    end

    class Or < SearchCondition
    end

    class And < SearchCondition
    end

    class Exists < Node
      def initialize(table_subquery)
        @table_subquery = table_subquery
      end

      attr_reader :table_subquery
    end

    class ComparisonPredicate < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_reader :left, :right
    end

    class Is < ComparisonPredicate
    end

    class Like < ComparisonPredicate
    end

    class In < ComparisonPredicate
    end

    class InValueList < Node
      def initialize(values)
        @values = values
      end

      attr_reader :values
    end

    class InColumnList < Node
      def initialize(columns)
        @columns = columns
      end

      attr_reader :columns
    end

    class Between < Node
      def initialize(left, min, max)
        @left = left
        @min = min
        @max = max
      end

      attr_reader :left, :min, :max
    end

    class GreaterOrEquals < ComparisonPredicate
    end

    class LessOrEquals < ComparisonPredicate
    end

    class Greater < ComparisonPredicate
    end

    class Less < ComparisonPredicate
    end

    class Equals < ComparisonPredicate
    end

    class Aggregate < Node
      def initialize(column)
        @column = column
      end

      attr_reader :column
    end

    class Sum < Aggregate
    end

    class Minimum < Aggregate
    end

    class Maximum < Aggregate
    end

    class Average < Aggregate
    end

    class Count < Aggregate
    end

    class JoinedTable < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_reader :left, :right
    end

    class CrossJoin < JoinedTable
    end

    class QualifiedJoin < JoinedTable
      def initialize(left, right, search_condition)
        super(left, right)
        @search_condition = search_condition
      end

      attr_reader :search_condition
    end

    class InnerJoin < QualifiedJoin
    end

    class LeftJoin < QualifiedJoin
    end

    class LeftOuterJoin < QualifiedJoin
    end

    class RightJoin < QualifiedJoin
    end

    class RightOuterJoin < QualifiedJoin
    end

    class FullJoin < QualifiedJoin
    end

    class FullOuterJoin < QualifiedJoin
    end

    class QualifiedColumn < Node
      def initialize(table, column)
        @table = table
        @column = column
      end

      attr_reader :table, :column
    end

    class Identifier < Node
      def initialize(name)
        @name = name
      end

      attr_reader :name
    end

    class Table < Identifier
    end

    class Column < Identifier
    end

    class As < Node
      def initialize(value, column)
        @value = value
        @column = column
      end

      attr_reader :value, :column
    end

    class Arithmetic < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_reader :left, :right
    end

    class Multiply < Arithmetic
    end

    class Divide < Arithmetic
    end

    class Add < Arithmetic
    end

    class Subtract < Arithmetic
    end

    class Unary < Node
      def initialize(value)
        @value = value
      end

      attr_reader :value
    end

    class Not < Unary
    end

    class UnaryPlus < Unary
    end

    class UnaryMinus < Unary
    end

    class CurrentUser < Node
    end

    class True < Node
    end

    class False < Node
    end

    class Null < Node
    end

    class Literal < Node
      def initialize(value)
        @value = value
      end

      attr_reader :value
    end

    class DateTime < Literal
    end

    class Date < Literal
    end

    class String < Literal
    end

    class ApproximateFloat < Node
      def initialize(mantissa, exponent)
        @mantissa = mantissa
        @exponent = exponent
      end

      attr_reader :mantissa, :exponent
    end

    class Float < Literal
    end

    class Integer < Literal
    end
  end
end
