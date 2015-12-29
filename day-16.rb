#!/usr/bin/env ruby
# http://adventofcode.com/day/16

input = STDIN.read

# I don't know if this is the same for all AoC players, but I'm hardcoding it here to match
# with the current scheme.

matching_input = {
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1
}

class Sue
  attr_reader :number, :values

  def initialize(number, values)
    @number = number
    @values = values
  end

  def to_s
    "Sue #{number}: #{values}"
  end
end

sues = input.split("\n").map do |str|
  number, value_s = /Sue (\d+): (.*)$/.match(str).captures
  values = value_s.split(',').flat_map do |s|
    a = s.split(':').map(&:strip)
    [a[0].intern, a[1].to_i]
  end

  Sue.new(number, Hash[*values])
end

matching_sue = sues.find do |sue|
  sue.values.all? { |k,v| matching_input.fetch(k) == v }
end

puts "Part 1: Sue #{matching_sue.number}"

part_2_sue = sues.find do |sue|
  gt_match = %i{ cats trees }.all? do |key|
    # In particular, the cats and trees readings indicates that there are greater than that many (due to the unpredictable nuclear decay of cat dander and tree pollen),
    if sue.values.has_key?(key)
      sue.values[key] > matching_input[key]
    else
      true
    end
  end

  lt_match = %i{ pomeranians goldfish }.all? do |key|
    # while the pomeranians and goldfish readings indicate that there are fewer than that many (due to the modial interaction of magnetoreluctance).
    if sue.values.has_key?(key)
      sue.values[key] < matching_input[key]
    else
      true
    end
  end

  em_match = %i{ children samoyeds akitas vizslas cars perfumes }.all? do |key|
    if sue.values.has_key?(key)
      sue.values[key] == matching_input[key]
    else
      true
    end
  end

  gt_match && lt_match && em_match
end

puts "Part 2: Sue #{part_2_sue.number}"
