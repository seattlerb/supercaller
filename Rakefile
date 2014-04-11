# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/super_caller.rb'

Hoe.new('SuperCaller', SuperCaller::VERSION) do |p|
  p.author = 'Eric Hodel'
  p.email = 'drbrain@segment7.net'
  p.summary = p.paragraphs_of('README.txt', 1).first
  p.description = p.paragraphs_of('README.txt', 7).first
  p.url = p.paragraphs_of('README.txt', 3).first
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")

  p.extra_deps << ['ParseTree', '~> 2.0']
  p.extra_deps << ['ruby2ruby', '~> 1.1']
end

# vim: syntax=Ruby
