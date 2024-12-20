# frozen_string_literal: true

require 'rossoc/frontend'

RSpec.describe Rossoc::Frontend do
  let(:input) { 'SELECT din1 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9) RSLEEP 100' }

  let(:rsleep_input1) { 'SELECT din1 FROM mruby RSLEEP 0' }
  let(:rsleep_input2) { 'SELECT din1 FROM mruby RSLEEP 1' }
  let(:rsleep_input3) { 'SELECT din1 FROM mruby RSLEEP 1.23' }

  it 'Parsing successful' do
    client = Rossoc::Frontend.new(input)
    expect(client.send(:parser, input)).not_to be_nil
  end

  it 'Parsing RSLEEP' do
    client = Rossoc::Frontend.new(rsleep_input1)
    expect(client.send(:parser, rsleep_input1)).not_to be_nil

    client = Rossoc::Frontend.new(rsleep_input2)
    expect(client.send(:parser, rsleep_input2)).not_to be_nil

    client = Rossoc::Frontend.new(rsleep_input3)
    expect(client.send(:parser, rsleep_input3)).not_to be_nil
  end

  it 'RSLEEP positive functions' do
    r_sleep = Rossoc::Ir::Rsleep.new(100)
    expect(r_sleep.positive?).to eq true
    expect(r_sleep.second).to eq 100
    expect(r_sleep.millisecond).to eq 100 * 1000
  end

  it 'RSLEEP zero functions' do
    r_sleep = Rossoc::Ir::Rsleep.new(0)
    expect(r_sleep.positive?).to eq false
    expect(r_sleep.second).to eq 0
    expect(r_sleep.millisecond).to eq 0
  end
end
