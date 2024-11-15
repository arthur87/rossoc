# frozen_string_literal: true

require 'bundler/gem_tasks'
task default: %i[]

PARSER = 'lib/rossoc/parser.racc'
LEXER = 'lib/rossoc/parser.rex'

task :parser do
  system "rm #{PARSER}.rb #{LEXER}.rb"
  system "racc -o #{PARSER}.rb #{PARSER}"
  system "rex -o #{LEXER}.rb #{LEXER}"
  system 'rspec'
end
