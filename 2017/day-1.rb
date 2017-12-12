#!/usr/bin/env ruby
# http://adventofcode.com/2017/day/1

stdin_input = STDIN.read.strip

def sum_if_match(input, step)
  sum = 0
  input_length = input.length

  for i in 0...input_length
    current_char  = input[i].to_i
    next_char     = input[(i + step) % input_length].to_i

    if current_char == next_char
      sum += current_char
    end
  end

  sum
end

def part_one(input)
  sum_if_match(input, 1)
end

def part_two(input)
  sum_if_match(input, input.length / 2)
end

part_one_solution = part_one(stdin_input)
part_two_solution = part_two(stdin_input)

puts "Pt 1: #{part_one_solution}"
puts "Pt 2: #{part_two_solution}"
