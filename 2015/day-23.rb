#!/usr/bin/env ruby
# http://adventofcode.com/day/23

input = STDIN.read
lines = input.split("\n").map(&:strip)
require 'logger'

class Computer
  def initialize(registers:, instructions:)
    @registers = Hash.new { |h, k| h[k] = 0 }
    registers.each { |n| @registers[n] }

    @instructions = instructions
    @current_instruction_index = 0
  end

  def run
    tick while current_instruction
  end

  def tick
    return unless current_instruction

    puts [
      "INS #{@current_instruction_index.to_s.ljust(4)}",
      "REG A #{register(:a)}".ljust(14),
      "REG B #{register(:b)}".ljust(14),
      current_instruction
    ].join(" ")

    case current_instruction[0...3]
    when 'hlf'
      half_register

    when 'tpl'
      triple_register

    when 'inc'
      increment_register

    when 'jmp'
      jump

    when 'jie'
      jump_if_even

    when 'jio'
      jump_if_odd

    else
      raise "Weird instruction #{current_instruction}"
    end
  end

  def register(n)
    @registers[n.intern]
  end

  private

  def current_instruction
    @instructions[@current_instruction_index]
  end

  def current_register_name
    current_instruction[4].intern
  end

  def current_register_value
    @registers[current_register_name]
  end

  def next_instruction
    @current_instruction_index += 1
  end

  def half_register
    @registers[current_register_name] /= 2
    next_instruction
  end

  def triple_register
    @registers[current_register_name] *= 3
    next_instruction
  end

  def increment_register
    @registers[current_register_name] += 1
    next_instruction
  end

  def jump
    jump_from_substring(4..-1)
  end

  def jump_if_even
    if current_register_value % 2 == 0
      jump_from_substring(7..-1)
    else
      next_instruction
    end
  end

  def jump_if_odd
    if current_register_value % 2 == 1
      jump_from_substring(7..-1)
    else
      next_instruction
    end
  end

  def jump_from_substring(range)
    jump_distance = current_instruction[range].to_i
    @current_instruction_index += jump_distance
  end
end

computer = Computer.new(
  registers: [:a, :b],
  instructions: lines
)

computer.run

puts "Part 1: #{computer.register(:b)}"
