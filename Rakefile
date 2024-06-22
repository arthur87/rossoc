# frozen_string_literal: true

require 'bundler/gem_tasks'
task default: %i[]

GENERATED_PARSER = 'lib/rossoc/parser.racc.rb'
GENERATED_LEXER = 'lib/rossoc/parser.rex.rb'

file GENERATED_LEXER => 'lib/rossoc/parser.rex' do |t|
  sh "rex -o #{t.name} #{t.prerequisites.first}"
end

file GENERATED_PARSER => 'lib/rossoc/parser.racc' do |t|
  sh "racc -o #{t.name} #{t.prerequisites.first}"
end

task parser: [GENERATED_LEXER, GENERATED_PARSER]

# Make sure the parser's up-to-date when we test.
# Rake::Task['test'].prerequisites << :parser
