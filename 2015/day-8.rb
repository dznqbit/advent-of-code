#!/usr/bin/env ruby
# http://adventofcode.com/day/8
# 1083 too low
# incorrect: 1084, 1096, 1341

# Part 2: 829 too low, 1474 too low
$: << (File.join(`pwd`.chomp, 'lib'))

input = STDIN.read

require 'logger'

def line_length(line)
  line.length
end

def escaped_line_length(line)
  # double-quotes on either side
  # \\ (which represents a single backslash)
  # \" (which represents a lone double-quote character)
  # \x plus two hexadecimal characters (which represents a single character with that ASCII code)

  all_escape_char_matcher = /(\\\\|\\"|\\x[a-f0-9]{2})/

  # Strip surrounding double-quotes
  cleaned_line = line[1...-1]

  num_escape_chars      = cleaned_line.scan(all_escape_char_matcher).count
  num_simple_characters = cleaned_line.gsub(all_escape_char_matcher, '').length

  num_simple_characters + num_escape_chars
end

def encode_line(line)
  ec = line.split('').reduce('') do |memo, s|
    memo += s.
      gsub("\\", "\\\\\\\\").
      gsub("\"", "\\\"")
  end

  "\"#{ec}\""
end

def encoded_line_length(line)
  encode_line(line).length
end

lines_and_lengths = input.split("\n").map do |line|
  [
    line,
    line_length(line),
    escaped_line_length(line),
    encoded_line_length(line)
  ]
end

raw_lengths     = lines_and_lengths.map { |l| l[1] }.reduce(0, :+)
escaped_lengths = lines_and_lengths.map { |l| l[2] }.reduce(0, :+)
encoded_lengths = lines_and_lengths.map { |l| l[3] }.reduce(0, :+)

puts "Part 1: #{raw_lengths} - #{escaped_lengths} = #{raw_lengths - escaped_lengths}"
puts "Part 2: #{encoded_lengths} - #{raw_lengths} = #{encoded_lengths - raw_lengths}"
