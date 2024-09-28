# frozen_string_literal: true

require 'rossoc/frontend'
require 'rossoc/ir'
require 'rossoc/backend'

RSpec.describe Rossoc::Backend do
  it 'mruby check successful' do
    frontend = Rossoc::Frontend.new('SELECT din1 FROM mruby')
    backend = Rossoc::Backend.new(frontend.ir, '')
    expect(backend.generate).not_to be_nil
  end
  it 'arduino check successful' do
    frontend = Rossoc::Frontend.new('SELECT din1 FROM arduino')
    backend = Rossoc::Backend.new(frontend.ir, '')
    expect(backend.generate).not_to be_nil
  end

  it 'dev check successful' do
    frontend = Rossoc::Frontend.new('SELECT din1 FROM dev')
    backend = Rossoc::Backend.new(frontend.ir, '')
    expect(backend.generate).not_to be_nil
  end
end
