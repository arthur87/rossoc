# frozen_string_literal: true

#
# Original source code
# sql-parser
# https://github.com/cryodex/sql-parser
#

require 'rossoc/statement'
require 'rossoc/sql_visitor'
require 'rossoc/parser.racc'

RSpec.describe SQLParser::Statement do
  it 'direct_select' do
    assert_sql 'SELECT * FROM `users` ORDER BY `name`',
               SQLParser::Statement::DirectSelect.new(select(all, tblx(from(tbl('users')))), SQLParser::Statement::OrderBy.new(col('name')))
  end

  it 'order_by' do
    assert_sql 'ORDER BY `name`', SQLParser::Statement::OrderBy.new(col('name'))
  end

  it 'subquery' do
    assert_sql '(SELECT 1)', SQLParser::Statement::Subquery.new(select(int(1)))
  end

  it 'select' do
    assert_sql 'SELECT 1', select(int(1))
    assert_sql 'SELECT * FROM `users`', select(all, tblx(from(tbl('users'))))
  end

  it 'select_list' do
    assert_sql '`id`', slist(col('id'))
    assert_sql '`id`, `name`', slist([col('id'), col('name')])
  end

  it 'distinct' do
    assert_sql 'DISTINCT(`username`)', distinct(col('username'))
  end

  it 'all' do
    assert_sql '*', all
  end

  it 'table_expression' do
    assert_sql 'FROM `users` WHERE `id` = 1 GROUP BY `name`', tblx(from(tbl('users')), where(equals(col('id'), int(1))), group_by(col('name')))
  end

  it 'from_clause' do
    assert_sql 'FROM `users`', from(tbl('users'))
  end

  it 'full_outer_join' do
    assert_sql '`t1` FULL OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::FullOuterJoin.new(tbl('t1'), tbl('t2'),
                                                       SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
    assert_sql '`t1` FULL OUTER JOIN `t2` USING (`a`)',
               SQLParser::Statement::FullOuterJoin.new(tbl('t1'), tbl('t2'), SQLParser::Statement::Using.new(col('a')))
  end

  it 'full_join' do
    assert_sql '`t1` FULL JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::FullJoin.new(tbl('t1'), tbl('t2'),
                                                  SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
  end

  it 'right_outer_join' do
    assert_sql '`t1` RIGHT OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::RightOuterJoin.new(tbl('t1'), tbl('t2'),
                                                        SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
  end

  it 'right_join' do
    assert_sql '`t1` RIGHT JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::RightJoin.new(tbl('t1'), tbl('t2'),
                                                   SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
  end

  it 'left_outer_join' do
    assert_sql '`t1` LEFT OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::LeftOuterJoin.new(tbl('t1'), tbl('t2'),
                                                       SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
  end

  it 'left_join' do
    assert_sql '`t1` LEFT JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::LeftJoin.new(tbl('t1'), tbl('t2'),
                                                  SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
  end

  it 'inner_join' do
    assert_sql '`t1` INNER JOIN `t2` ON `t1`.`a` = `t2`.`a`',
               SQLParser::Statement::InnerJoin.new(tbl('t1'), tbl('t2'),
                                                   SQLParser::Statement::On.new(equals(qcol(tbl('t1'), col('a')), qcol(tbl('t2'), col('a')))))
  end

  it 'cross_join' do
    assert_sql '`t1` CROSS JOIN `t2`', SQLParser::Statement::CrossJoin.new(tbl('t1'), tbl('t2'))
    assert_sql '`t1` CROSS JOIN `t2` CROSS JOIN `t3`',
               SQLParser::Statement::CrossJoin.new(SQLParser::Statement::CrossJoin.new(tbl('t1'), tbl('t2')), tbl('t3'))
  end

  it 'order_clause' do
    assert_sql 'ORDER BY `name` DESC', SQLParser::Statement::OrderClause.new(SQLParser::Statement::Descending.new(col('name')))
    assert_sql 'ORDER BY `id` ASC, `name` DESC',
               SQLParser::Statement::OrderClause.new([SQLParser::Statement::Ascending.new(col('id')),
                                                      SQLParser::Statement::Descending.new(col('name'))])
  end

  it 'having_clause' do
    assert_sql 'HAVING `id` = 1', SQLParser::Statement::HavingClause.new(equals(col('id'), int(1)))
  end

  it 'group_by_clause' do
    assert_sql 'GROUP BY `name`', group_by(col('name'))
    assert_sql 'GROUP BY `name`, `status`', group_by([col('name'), col('status')])
  end

  it 'where_clause' do
    assert_sql 'WHERE 1 = 1', where(equals(int(1), int(1)))
  end

  it 'or' do
    assert_sql '(FALSE OR FALSE)', SQLParser::Statement::Or.new(SQLParser::Statement::False.new, SQLParser::Statement::False.new)
  end

  it 'and' do
    assert_sql '(TRUE AND TRUE)', SQLParser::Statement::And.new(SQLParser::Statement::True.new, SQLParser::Statement::True.new)
  end

  it 'is_not_null' do
    assert_sql '1 IS NOT NULL', SQLParser::Statement::Not.new(SQLParser::Statement::Is.new(int(1), SQLParser::Statement::Null.new))
  end

  it 'is_null' do
    assert_sql '1 IS NULL', SQLParser::Statement::Is.new(int(1), SQLParser::Statement::Null.new)
  end

  it 'not_like' do
    assert_sql "'hello' NOT LIKE 'h%'", SQLParser::Statement::Not.new(SQLParser::Statement::Like.new(str('hello'), str('h%')))
  end

  it 'like' do
    assert_sql "'hello' LIKE 'h%'", SQLParser::Statement::Like.new(str('hello'), str('h%'))
  end

  it 'not_in' do
    assert_sql '1 NOT IN (1, 2, 3)',
               SQLParser::Statement::Not.new(SQLParser::Statement::In.new(int(1), SQLParser::Statement::InValueList.new([int(1), int(2), int(3)])))
  end

  it 'in' do
    assert_sql '1 IN (1, 2, 3)', SQLParser::Statement::In.new(int(1), SQLParser::Statement::InValueList.new([int(1), int(2), int(3)]))
  end

  it 'not_between' do
    assert_sql '2 NOT BETWEEN 1 AND 3', SQLParser::Statement::Not.new(SQLParser::Statement::Between.new(int(2), int(1), int(3)))
  end

  it 'between' do
    assert_sql '2 BETWEEN 1 AND 3', SQLParser::Statement::Between.new(int(2), int(1), int(3))
  end

  it 'gte' do
    assert_sql '1 >= 1', SQLParser::Statement::GreaterOrEquals.new(int(1), int(1))
  end

  it 'lte' do
    assert_sql '1 <= 1', SQLParser::Statement::LessOrEquals.new(int(1), int(1))
  end

  it 'gt' do
    assert_sql '1 > 1', SQLParser::Statement::Greater.new(int(1), int(1))
  end

  it 'lt' do
    assert_sql '1 < 1', SQLParser::Statement::Less.new(int(1), int(1))
  end

  it 'not_equals' do
    assert_sql '1 <> 1', SQLParser::Statement::Not.new(equals(int(1), int(1)))
  end

  it 'equals' do
    assert_sql '1 = 1', equals(int(1), int(1))
  end

  it 'sum' do
    assert_sql 'SUM(`messages_count`)', SQLParser::Statement::Sum.new(col('messages_count'))
  end

  it 'minimum' do
    assert_sql 'MIN(`age`)', SQLParser::Statement::Minimum.new(col('age'))
  end

  it 'maximum' do
    assert_sql 'MAX(`age`)', SQLParser::Statement::Maximum.new(col('age'))
  end

  it 'average' do
    assert_sql 'AVG(`age`)', SQLParser::Statement::Average.new(col('age'))
  end

  it 'count' do
    assert_sql 'COUNT(*)', SQLParser::Statement::Count.new(all)
  end

  it 'table' do
    assert_sql '`users`', tbl('users')
  end

  it 'qualified_column' do
    assert_sql '`users`.`id`', qcol(tbl('users'), col('id'))
  end

  it 'column' do
    assert_sql '`id`', col('id')
  end

  it 'as' do
    assert_sql '1 AS `a`', SQLParser::Statement::As.new(int(1), col('a'))
  end

  it 'multiply' do
    assert_sql '(2 * 2)', SQLParser::Statement::Multiply.new(int(2), int(2))
  end

  it 'divide' do
    assert_sql '(2 / 2)', SQLParser::Statement::Divide.new(int(2), int(2))
  end

  it 'add' do
    assert_sql '(2 + 2)', SQLParser::Statement::Add.new(int(2), int(2))
  end

  it 'subtract' do
    assert_sql '(2 - 2)', SQLParser::Statement::Subtract.new(int(2), int(2))
  end

  it 'unary_plus' do
    assert_sql '+1', SQLParser::Statement::UnaryPlus.new(int(1))
  end

  it 'unary_minus' do
    assert_sql '-1', SQLParser::Statement::UnaryMinus.new(int(1))
  end

  it 'true' do
    assert_sql 'TRUE', SQLParser::Statement::True.new
  end

  it 'false' do
    assert_sql 'FALSE', SQLParser::Statement::False.new
  end

  it 'null' do
    assert_sql 'NULL', SQLParser::Statement::Null.new
  end

  it 'current_user' do
    assert_sql 'CURRENT_USER', SQLParser::Statement::CurrentUser.new
  end

  it 'datetime' do
    assert_sql "'2008-07-01 12:34:56'", SQLParser::Statement::DateTime.new(Time.local(2008, 7, 1, 12, 34, 56))
  end

  it 'date' do
    assert_sql "DATE '2008-07-01'", SQLParser::Statement::Date.new(Date.new(2008, 7, 1))
  end

  it 'string' do
    assert_sql "'foo'", str('foo')

    # # FIXME
    # assert_sql "'O\\\'rly'", str("O'rly")
  end

  it 'approximate_float' do
    assert_sql '1E1', SQLParser::Statement::ApproximateFloat.new(int(1), int(1))
  end

  it 'float' do
    assert_sql '1.1', SQLParser::Statement::Float.new(1.1)
  end

  it 'integer' do
    assert_sql '1', int(1)
  end

  private

  def assert_sql(expected, ast)
    #    assert_equal expected, ast.to_sql

    expect(ast.to_sql).to eq expected
  end

  def qcol(table, column)
    SQLParser::Statement::QualifiedColumn.new(table, column)
  end

  def equals(left, right)
    SQLParser::Statement::Equals.new(left, right)
  end

  def all
    SQLParser::Statement::All.new
  end

  def str(value)
    SQLParser::Statement::String.new(value)
  end

  def int(value)
    SQLParser::Statement::Integer.new(value)
  end

  def col(name)
    SQLParser::Statement::Column.new(name)
  end

  def tbl(name)
    SQLParser::Statement::Table.new(name)
  end

  def distinct(col)
    SQLParser::Statement::Distinct.new(col)
  end

  def slist(ary)
    SQLParser::Statement::SelectList.new(ary)
  end

  def select(list, table_expression = nil)
    SQLParser::Statement::Select.new(list, table_expression)
  end

  def tblx(from_clause, where_clause = nil, group_by_clause = nil, having_clause = nil)
    SQLParser::Statement::TableExpression.new(from_clause, where_clause, group_by_clause, having_clause)
  end

  def from(tables)
    SQLParser::Statement::FromClause.new(tables)
  end

  def where(search_condition)
    SQLParser::Statement::WhereClause.new(search_condition)
  end

  def group_by(columns)
    SQLParser::Statement::GroupByClause.new(columns)
  end
end
