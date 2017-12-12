#!/usr/bin/env ruby
# Advent of Code, Day 2
# https://adventofcode.com/2017/day/2
# https://github.com/dznqbit/advent-of-code

input = STDIN.read

# Find a checksum
# @param Array[Array[Number]]
# @return Number the spreadsheet checksum
def find_checksum_pt1(spreadsheet_rows)
  spreadsheet_rows.reduce(0) do |sum, row|
    # Find the largest and the smallest number
    largest = row[-1]
    smallest = row[0]
    difference = largest - smallest

    sum + difference
  end
end

# Can +dividend+ be divided by +divisor+ cleanly?
def divides_nicely?(divisor, dividend)
  [
    (dividend / divisor) > 0, # Divides at least once
    (dividend % divisor) == 0 # Divides with no remainder
  ].all?
end

# Find the pair of numbers that are perfectly divisible, sum their difference
# @param Array[Array[Number]]
# @return Number the spreadsheet checksum
def find_checksum_pt2(spreadsheet_rows)
  spreadsheet_rows.reduce(0) do |sum, row|
    (divisor, dividend) = row.
      combination(2).
      find do |(val, c_val)|
        case
        when divides_nicely?(val, c_val)  then [val, c_val]
        when divides_nicely?(c_val, val)  then [c_val, val]
        end
      end

    q = (dividend / divisor)

    sum + q
  end
end

spreadsheet_rows = input.
  split("\n").
  map do |row|
    row.
      split(/\s/).
      map(&:to_i).
      sort
  end

checksum_pt_1 = find_checksum_pt1(spreadsheet_rows)
puts "Pt 1: #{checksum_pt_1}"

checksum_pt_2 = find_checksum_pt2(spreadsheet_rows)
puts "Pt 2: #{checksum_pt_2}"
