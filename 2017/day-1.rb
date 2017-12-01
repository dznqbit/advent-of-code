#!/usr/bin/env ruby
# http://adventofcode.com/2017/day/1

stdin_input = STDIN.read.strip

def part_one(input)
  sum = 0

  for i in 0...input.length
    current_char = input[i].to_i
    next_char = (input[i+1] || input[0]).to_i

    if current_char == next_char
      sum += current_char
    end
  end

  sum
end

def part_two(input)
  sum = 0
  input_length = input.length
  step = input_length / 2

  for i in 0...input_length
    current_char = input[i].to_i
    next_char = input[(i + step) % input_length].to_i

    if current_char == next_char
      sum += current_char
    end
  end

  sum
end

part_one_solution = part_one(stdin_input)
part_two_solution = part_two(stdin_input)

puts "Part 1: #{part_one_solution}"
puts "Part 2: #{part_two_solution}"
