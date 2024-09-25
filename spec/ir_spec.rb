# frozen_string_literal: true

require 'rossoc/frontend'

RSpec.describe Rossoc::Frontend do
  let(:input) { 'SELECT din1 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9) RSLEEP 100' }

  it 'Parsing successful' do
    client = Rossoc::Frontend.new(input)
    expect(client.send(:parser, input)).not_to be_nil
  end


end
