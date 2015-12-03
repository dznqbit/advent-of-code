#!/usr/bin/env ruby
# http://adventofcode.com/day/3

class Coordinate
  attr_reader :longitude, :latitude

  # Longitude :: X, Latitude :: Y
  def initialize(longitude, latitude)
    @longitude = longitude
    @latitude = latitude
  end

  def to_s
    "#{longitude}x#{latitude}"
  end

  def move(instruction)
    case instruction
    when '<'
      Coordinate.new(longitude - 1, latitude)
    when '^'
      Coordinate.new(longitude, latitude + 1)
    when '>'
      Coordinate.new(longitude + 1, latitude)
    when 'v'
      Coordinate.new(longitude, latitude - 1)
    else
      self
    end
  end
end

def present_hash
  h = Hash.new { |h,k| h[k] = 0 }
  h.instance_eval do
    def deliver!(coordinate)
      self[coordinate.to_s] += 1
    end
  end
  h
end

# He begins by delivering a present to the house at his starting location
# After each move, he delivers another present to the house at his new location.

house_present_count = present_hash

input = STDIN.read

santas_current_coordinate = Coordinate.new(0, 0)
house_present_count.deliver!(santas_current_coordinate)

input.each_char do |instruction|
  santas_current_coordinate = santas_current_coordinate.move(instruction)
  house_present_count.deliver!(santas_current_coordinate)
end

puts "Part 1: #{house_present_count.keys.count}"

# The next year, to speed up the process, Santa creates a robot version of himself,
# Robo-Santa, to deliver presents with him.

# Santa and Robo-Santa start at the same location
# (delivering two presents to the same starting house),
# then take turns moving based on instructions from the elf,
# who is eggnoggedly reading from the same script as the previous year.

house_present_count = present_hash

santas_current_coordinate = Coordinate.new(0, 0)
robo_santas_current_coordinate = Coordinate.new(0, 0)

house_present_count.deliver!(santas_current_coordinate)
house_present_count.deliver!(robo_santas_current_coordinate)

input.split('').each_slice(2) do |santa_instruction, robo_santa_instruction|
  santas_current_coordinate = santas_current_coordinate.move(santa_instruction)
  robo_santas_current_coordinate = robo_santas_current_coordinate.move(robo_santa_instruction)

  house_present_count.deliver!(santas_current_coordinate)
  house_present_count.deliver!(robo_santas_current_coordinate)
end

puts "Part 2: #{house_present_count.keys.count}"
