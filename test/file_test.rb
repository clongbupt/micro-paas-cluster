#!/usr/bin/env ruby
# coding : UTF-8

require "pathname"

BASE_DIR = File.dirname(__FILE__)

file = Pathname.new(BASE_DIR + "file.log")

str = "dfadfadfadf"

File.open(file,"w") do |handler|
  handler.print str
end