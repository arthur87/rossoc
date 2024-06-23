# frozen_string_literal: true

require 'rossoc/frontend'

RSpec.describe Rossoc::Frontend do
  it 'syntax check' do
    sql = 'SELECT din11 FROM board WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9) RSLEEP 100'
    client = Rossoc::Frontend.new(sql)
    client.send(:parser, sql)
  end
end
