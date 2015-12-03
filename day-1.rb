#!/usr/bin/env ruby
# http://adventofcode.com/day/1

input = STDIN.read

directions = input.split('').map do |s|
  case s
  when '(' then 1
  when ')' then -1
  else 0
  end
end

final_floor = directions.reduce(0) { |m, i| m += i }

puts "Part 1: #{final_floor}"

# Part ii, this is sloppy but gets the job done.

current_floor = 0
index_of_first_basement_transgression = nil

directions.each_with_index do |d, i|
  current_floor += d

  if current_floor < 0
    index_of_first_basement_transgression = i
    break
  end
end

# Per the problem, 'instructions' are 1-based
puts "Part 2: #{index_of_first_basement_transgression + 1}"
