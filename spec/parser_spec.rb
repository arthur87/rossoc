# frozen_string_literal: true

#
# Original source code
# sql-parser
# https://github.com/cryodex/sql-parser
#

require 'rossoc/sql_visitor'
require 'rossoc/parser.racc'

RSpec.describe SQLParser::Parser do
  it 'current_user' do
    assert_understands 'SELECT CURRENT_USER'
    assert_understands 'SELECT `CURRENT_USER`'
    assert_understands 'SELECT `current_user`'
  end

  it 'case_insensitivity' do
    assert_sql 'SELECT * FROM `users` WHERE `id` = 1', 'select * from users where id = 1'
  end

  it 'subquery_in_where_clause' do
    assert_understands 'SELECT * FROM `t1` WHERE `id` > (SELECT SUM(`a`) FROM `t2`)'
  end

  it 'order_by_constant' do
    assert_sql 'SELECT * FROM `users` ORDER BY 1 ASC', 'SELECT * FROM users ORDER BY 1'
    assert_understands 'SELECT * FROM `users` ORDER BY 1 ASC'
    assert_understands 'SELECT * FROM `users` ORDER BY 1 DESC'
  end

  it 'order' do
    assert_sql 'SELECT * FROM `users` ORDER BY `name` ASC', 'SELECT * FROM users ORDER BY name'
    assert_understands 'SELECT * FROM `users` ORDER BY `name` ASC'
    assert_understands 'SELECT * FROM `users` ORDER BY `name` DESC'
  end

  it 'full_outer_join' do
    assert_understands 'SELECT * FROM `t1` FULL OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` FULL OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a` FULL OUTER JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` FULL OUTER JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` FULL OUTER JOIN `t2` USING (`a`) FULL OUTER JOIN `t3` USING (`b`)'
  end

  it 'full_join' do
    assert_understands 'SELECT * FROM `t1` FULL JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` FULL JOIN `t2` ON `t1`.`a` = `t2`.`a` FULL JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` FULL JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` FULL JOIN `t2` USING (`a`) FULL JOIN `t3` USING (`b`)'
  end

  it 'right_outer_join' do
    assert_understands 'SELECT * FROM `t1` RIGHT OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` RIGHT OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a` RIGHT OUTER JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` RIGHT OUTER JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` RIGHT OUTER JOIN `t2` USING (`a`) RIGHT OUTER JOIN `t3` USING (`b`)'
  end

  it 'right_join' do
    assert_understands 'SELECT * FROM `t1` RIGHT JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` RIGHT JOIN `t2` ON `t1`.`a` = `t2`.`a` RIGHT JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` RIGHT JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` RIGHT JOIN `t2` USING (`a`) RIGHT JOIN `t3` USING (`b`)'
  end

  it 'left_outer_join' do
    assert_understands 'SELECT * FROM `t1` LEFT OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` LEFT OUTER JOIN `t2` ON `t1`.`a` = `t2`.`a` LEFT OUTER JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` LEFT OUTER JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` LEFT OUTER JOIN `t2` USING (`a`) LEFT OUTER JOIN `t3` USING (`b`)'
  end

  it 'left_join' do
    assert_understands 'SELECT * FROM `t1` LEFT JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` LEFT JOIN `t2` ON `t1`.`a` = `t2`.`a` LEFT JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` LEFT JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` LEFT JOIN `t2` USING (`a`) LEFT JOIN `t3` USING (`b`)'
  end

  it 'inner_join' do
    assert_understands 'SELECT * FROM `t1` INNER JOIN `t2` ON `t1`.`a` = `t2`.`a`'
    assert_understands 'SELECT * FROM `t1` INNER JOIN `t2` ON `t1`.`a` = `t2`.`a` INNER JOIN `t3` ON `t2`.`a` = `t3`.`a`'
    assert_understands 'SELECT * FROM `t1` INNER JOIN `t2` USING (`a`)'
    assert_understands 'SELECT * FROM `t1` INNER JOIN `t2` USING (`a`) INNER JOIN `t3` USING (`b`)'
  end

  it 'cross_join' do
    assert_understands 'SELECT * FROM `t1` CROSS JOIN `t2`'
    assert_understands 'SELECT * FROM `t1` CROSS JOIN `t2` CROSS JOIN `t3`'
  end

  # The expression
  #   SELECT * FROM t1, t2
  # is just syntactic sugar for
  #   SELECT * FROM t1 CROSS JOIN t2
  it 'cross_join_syntactic_sugar' do
    assert_sql 'SELECT * FROM `t1` CROSS JOIN `t2`', 'SELECT * FROM t1, t2'
    assert_sql 'SELECT * FROM `t1` CROSS JOIN `t2` CROSS JOIN `t3`', 'SELECT * FROM t1, t2, t3'
  end

  it 'having' do
    assert_understands 'SELECT * FROM `users` HAVING `id` = 1'
  end

  it 'group_by' do
    assert_understands 'SELECT * FROM `users` GROUP BY `name`'
    assert_understands 'SELECT * FROM `users` GROUP BY `users`.`name`'
    assert_understands 'SELECT * FROM `users` GROUP BY `name`, `id`'
    assert_understands 'SELECT * FROM `users` GROUP BY `users`.`name`, `users`.`id`'
  end

  it 'or' do
    assert_understands 'SELECT * FROM `users` WHERE (`id` = 1 OR `age` = 18)'
  end

  it 'and' do
    assert_understands 'SELECT * FROM `users` WHERE (`id` = 1 AND `age` = 18)'
  end

  it 'not' do
    assert_sql 'SELECT * FROM `users` WHERE `id` <> 1', 'SELECT * FROM users WHERE NOT id = 1'
    assert_sql 'SELECT * FROM `users` WHERE `id` NOT IN (1, 2, 3)', 'SELECT * FROM users WHERE NOT id IN (1, 2, 3)'
    assert_sql 'SELECT * FROM `users` WHERE `id` NOT BETWEEN 1 AND 3',
               'SELECT * FROM users WHERE NOT id BETWEEN 1 AND 3'
    assert_sql "SELECT * FROM `users` WHERE `name` NOT LIKE 'A%'", "SELECT * FROM users WHERE NOT name LIKE 'A%'"

    # Shouldn't negate subqueries
    assert_understands 'SELECT * FROM `users` WHERE NOT EXISTS (SELECT `id` FROM `users` WHERE `id` = 1)'
  end

  it 'not_exists' do
    assert_understands 'SELECT * FROM `users` WHERE NOT EXISTS (SELECT `id` FROM `users`)'
  end

  it 'exists' do
    assert_understands 'SELECT * FROM `users` WHERE EXISTS (SELECT `id` FROM `users`)'
  end

  it 'is_not_null' do
    assert_understands 'SELECT * FROM `users` WHERE `deleted_at` IS NOT NULL'
  end

  it 'is_null' do
    assert_understands 'SELECT * FROM `users` WHERE `deleted_at` IS NULL'
  end

  it 'not_like' do
    assert_understands "SELECT * FROM `users` WHERE `name` NOT LIKE 'Joe%'"
  end

  it 'like' do
    assert_understands "SELECT * FROM `users` WHERE `name` LIKE 'Joe%'"
  end

  it 'not_in' do
    assert_understands 'SELECT * FROM `users` WHERE `id` NOT IN (1, 2, 3)'
    assert_understands 'SELECT * FROM `users` WHERE `id` NOT IN (SELECT `id` FROM `users` WHERE `age` = 18)'
  end

  it 'in' do
    assert_understands 'SELECT * FROM `users` WHERE `id` IN (1, 2, 3)'
    assert_understands 'SELECT * FROM `users` WHERE `id` IN (SELECT `id` FROM `users` WHERE `age` = 18)'
  end

  it 'not_between' do
    assert_understands 'SELECT * FROM `users` WHERE `id` NOT BETWEEN 1 AND 3'
  end

  it 'between' do
    assert_understands 'SELECT * FROM `users` WHERE `id` BETWEEN 1 AND 3'
  end

  it 'gte' do
    assert_understands 'SELECT * FROM `users` WHERE `id` >= 1'
  end

  it 'lte' do
    assert_understands 'SELECT * FROM `users` WHERE `id` <= 1'
  end

  it 'gt' do
    assert_understands 'SELECT * FROM `users` WHERE `id` > 1'
  end

  it 'lt' do
    assert_understands 'SELECT * FROM `users` WHERE `id` < 1'
  end

  it 'not_equals' do
    assert_sql 'SELECT * FROM `users` WHERE `id` <> 1', 'SELECT * FROM users WHERE id != 1'
    assert_understands 'SELECT * FROM `users` WHERE `id` <> 1'
  end

  it 'equals' do
    assert_understands 'SELECT * FROM `users` WHERE `id` = 1'
  end
  it 'where_clause' do
    assert_understands 'SELECT * FROM `users` WHERE 1 = 1'
  end

  it 'sum' do
    assert_understands 'SELECT SUM(`messages_count`) FROM `users`'
  end

  it 'min' do
    assert_understands 'SELECT MIN(`age`) FROM `users`'
  end

  it 'max' do
    assert_understands 'SELECT MAX(`age`) FROM `users`'
  end

  it 'avg' do
    assert_understands 'SELECT AVG(`age`) FROM `users`'
  end

  it 'count' do
    assert_understands 'SELECT COUNT(*) FROM `users`'
    assert_understands 'SELECT COUNT(`id`) FROM `users`'
  end

  it 'from_clause' do
    assert_understands 'SELECT 1 FROM `users`'
    assert_understands 'SELECT `id` FROM `users`'
    assert_understands 'SELECT `users`.`id` FROM `users`'
    assert_understands 'SELECT * FROM `users`'
  end
  it 'select_list' do
    assert_understands 'SELECT 1, 2'
    assert_understands 'SELECT (1 + 1) AS `x`, (2 + 2) AS `y`'
    assert_understands 'SELECT `id`, `name`'
    assert_understands 'SELECT (`age` * 2) AS `double_age`, `first_name` AS `name`'
  end

  it 'as' do
    assert_understands 'SELECT 1 AS `x`'
    assert_sql 'SELECT 1 AS `x`', 'SELECT 1 x'

    assert_understands 'SELECT (1 + 1) AS `y`'
    assert_sql 'SELECT (1 + 1) AS `y`', 'SELECT (1 + 1) y'

    assert_understands 'SELECT * FROM `users` AS `u`'
    assert_sql 'SELECT * FROM `users` AS `u`', 'SELECT * FROM users u'
  end

  it 'parentheses' do
    assert_sql 'SELECT ((1 + 2) * ((3 - 4) / 5))', 'SELECT (1 + 2) * (3 - 4) / 5'
  end

  it 'order_of_operations' do
    assert_sql 'SELECT (1 + ((2 * 3) - (4 / 5)))', 'SELECT 1 + 2 * 3 - 4 / 5'
  end

  it 'numeric_value_expression' do
    assert_understands 'SELECT (1 * 2)'
    assert_understands 'SELECT (1 / 2)'
    assert_understands 'SELECT (1 + 2)'
    assert_understands 'SELECT (1 - 2)'
  end
  it 'quoted_identifier' do
    assert_sql 'SELECT `a`', 'SELECT `a`'
  end

  it 'date' do
    assert_sql "SELECT DATE '2008-07-11'", 'SELECT DATE "2008-07-11"'
    assert_understands "SELECT DATE '2008-07-11'"
  end

  it 'quoting' do
    assert_sql %(SELECT ''), %(SELECT "")
    assert_understands %(SELECT '')

    assert_sql %(SELECT 'Quote "this"'), %(SELECT "Quote ""this""")
    assert_understands %(SELECT 'Quote ''this!''')

    # # FIXME
    # assert_sql %{SELECT '"'}, %{SELECT """"}
    # assert_understands %{SELECT ''''}
  end

  it 'string' do
    assert_sql "SELECT 'abc'", 'SELECT "abc"'
    assert_understands "SELECT 'abc'"
  end
  it 'approximate_numeric_literal' do
    assert_understands 'SELECT 1E1'
    assert_understands 'SELECT 1E+1'
    assert_understands 'SELECT 1E-1'

    assert_understands 'SELECT +1E1'
    assert_understands 'SELECT +1E+1'
    assert_understands 'SELECT +1E-1'

    assert_understands 'SELECT -1E1'
    assert_understands 'SELECT -1E+1'
    assert_understands 'SELECT -1E-1'

    assert_understands 'SELECT 1.5E30'
    assert_understands 'SELECT 1.5E+30'
    assert_understands 'SELECT 1.5E-30'

    assert_understands 'SELECT +1.5E30'
    assert_understands 'SELECT +1.5E+30'
    assert_understands 'SELECT +1.5E-30'

    assert_understands 'SELECT -1.5E30'
    assert_understands 'SELECT -1.5E+30'
    assert_understands 'SELECT -1.5E-30'
  end

  it 'signed_float' do
    # Positives
    assert_sql 'SELECT +1', 'SELECT +1.'
    assert_sql 'SELECT +0.1', 'SELECT +.1'

    assert_understands 'SELECT +0.1'
    assert_understands 'SELECT +1.0'
    assert_understands 'SELECT +1.1'
    assert_understands 'SELECT +10.1'

    # Negatives
    assert_sql 'SELECT -1', 'SELECT -1.'
    assert_sql 'SELECT -0.1', 'SELECT -.1'

    assert_understands 'SELECT -0.1'
    assert_understands 'SELECT -1.0'
    assert_understands 'SELECT -1.1'
    assert_understands 'SELECT -10.1'
  end

  it 'unsigned_float' do
    assert_sql 'SELECT 1', 'SELECT 1.'
    assert_sql 'SELECT 0.1', 'SELECT .1'

    assert_understands 'SELECT 0.1'
    assert_understands 'SELECT 1.0'
    assert_understands 'SELECT 1.1'
    assert_understands 'SELECT 10.1'
  end

  it 'signed_integer' do
    assert_understands 'SELECT +1'
    assert_understands 'SELECT -1'
  end

  it 'unsigned_integer' do
    assert_understands 'SELECT 1'
    assert_understands 'SELECT 10'
  end

  private

  def assert_sql(expected, given)
    expect(SQLParser::Parser.parse(given).to_sql).to eq expected
  end

  def assert_understands(sql)
    assert_sql(sql, sql)
  end
end
