#!/usr/bin/env ruby
# http://adventofcode.com/day/10

input = STDIN.read

def char_chunk(s)
  s.split('').reduce([]) do |m, c|
    if m.last && m.last.start_with?(c)
      m.last << c
    else
      m << c
    end

    m
  end
end

def look_and_say(n)
  chunks = char_chunk(n.to_s)
  chunks.reduce('') do |m, s|
    n = s.length
    c = s[0]

    m += "#{n}#{c}"
  end
end

starting_number = input.chomp.to_i
said_number = starting_number

40.times do |i|
  said_number = look_and_say(said_number)
  puts "#{i}: #{said_number.length}"
end

puts "Part 1: #{said_number.length}"

10.times do |i|
  said_number = look_and_say(said_number)
  puts "#{40 + i}: #{said_number.length}"
end

puts "Part 2: #{said_number.length}"
