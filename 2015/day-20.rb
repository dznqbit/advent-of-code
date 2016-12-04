#!/usr/bin/env ruby
# http://adventofcode.com/day/20

input = STDIN.read
lines = input.split("\n").map(&:strip)
require 'logger'

##################################################################################################

House = Struct.new(:index, :present_count)
PRESENTS_PER_ELF = 10

def house_present_count(house_index)
  half = (house_index / 2)

  secondary_presents_delivered = half.downto(1).map do |index|
    if house_index % index == 0
      (index * PRESENTS_PER_ELF)
    end
  end.compact.reduce(0, :+)

  secondary_presents_delivered + (house_index * PRESENTS_PER_ELF)
end

##################################################################################################

target_present_count = lines.last.to_i

house_index = 1
houses = [House.new(house_index, house_present_count(house_index))]

while houses.last.present_count < target_present_count
  house = House.new(house_index, house_present_count(house_index))
  houses << house

  house_index += 1

  puts "Check House(#{house.index}) (PC #{house.present_count} #{house.present_count > target_present_count ? '>' : '<' } #{target_present_count})"
end

puts "Part 1: House(#{houses.last.index})"
