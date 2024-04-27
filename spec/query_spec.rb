# frozen_string_literal: true

require 'rossoc/query'

RSpec.describe Rossoc::Query do
  it 'syntax check' do
    sql = 'SELECT din11 FROM board WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)'
    client = Rossoc::Query.new(sql, nil)
    client.send(:parser, sql)
  end
end
