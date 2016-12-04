#!/usr/bin/env ruby
# http://adventofcode.com/day/18

input = STDIN.read

require 'logger'
@logger = Logger.new(STDOUT)

class LightGrid
  NEIGHBOR_OFFSETS = {
    0 => [ 0, -1],
    1 => [ 1, -1],
    2 => [ 1,  0],
    3 => [ 1,  1],
    4 => [ 0,  1],
    5 => [-1,  1],
    6 => [-1,  0],
    7 => [-1, -1]
  }

  module States
    ON  = '#'
    OFF = '.'
  end

  # +rows+ : Array of Array of String
  def initialize(rows)
    @rows = rows
  end

  # return a new LightGrid for the next "frame"
  def tick
    new_rows = (0...height).map do |row_i|
      (0...width).map do |col_j|
        next_light_state(col_j, row_i)
      end
    end

    self.class.new(new_rows)
  end

  def next_light_state(x, y)
    light = light(x, y)

    neighbors = (0..7).map do |neighbor_k|
      light_neighbor(x, y, neighbor_k)
    end

    num_turned_on_neighbors = neighbors.count { |n| n == States::ON }

    if light == States::ON
      if [2, 3].include?(num_turned_on_neighbors)
        States::ON
      else
        States::OFF
      end
    else
      if num_turned_on_neighbors == 3
        States::ON
      else
        States::OFF
      end
    end
  end

  # Will return ON or OFF
  def light(x, y)
    within_bounds = (0...width).include?(x) && (0...height).include?(y)

    if within_bounds
      @rows[y][x]
    else
      States::OFF
    end
  end

  def num_lights(state = States::ON)
    @rows.reduce(0) do |memo, r|
      memo += r.count { |l| l == state }
    end
  end

  # For the light, find its neighbors status (ON/OFF).
  #
  # 'Neighbors' look like this
  #
  # 7 0 1
  # 6 * 2
  # 5 4 3
  def light_neighbor(x, y, neighbor_index)
    neighbor_offset = NEIGHBOR_OFFSETS[neighbor_index]
    neighbor_x      = x + neighbor_offset[0]
    neighbor_y      = y + neighbor_offset[1]

    light(neighbor_x, neighbor_y)
  end

  def to_s
    @rows.map { |r| r.map(&:to_s).join('') }.join("\n")
  end

  private

  def width
    @rows.first.length
  end

  def height
    @rows.length
  end
end

rows        = input.split("\n").map { |r| r.split('') }
light_grid = LightGrid.new(rows)

num_ticks = 100

puts light_grid.to_s
puts "Ticks: 0"
puts "Num Lights: #{light_grid.num_lights} Lights On\n\n"

num_ticks.times do |i|
  light_grid = light_grid.tick

  puts light_grid.to_s
  puts "Ticks: #{i}/#{num_ticks}"
  puts "Num Lights: #{light_grid.num_lights} Lights On\n\n"
end

# 6, 988 is too low...
puts "\nPart 1: #{light_grid.num_lights} Lights On"

# ******
# PART 2
# ******

class StickyLightGrid < LightGrid
  def next_light_state(x, y)
    if [
        upper_left_corner, upper_right_corner,
        lower_left_corner, lower_right_corner
    ].include?([x, y])
      States::ON
    else
      super(x,y)
    end
  end

  private

  def upper_left_corner
    [0,         0]
  end

  def upper_right_corner
    [width - 1, 0]
  end

  def lower_left_corner
    [0,         height - 1]
  end

  def lower_right_corner
    [width - 1, height - 1]
  end
end

light_grid = StickyLightGrid.new(rows)

puts light_grid.to_s
puts "Ticks: 0"
puts "Num Lights: #{light_grid.num_lights} Lights On\n\n"

num_ticks = 100

num_ticks.times do |i|
  light_grid = light_grid.tick

  puts light_grid.to_s
  puts "Ticks: #{i + 1}/#{num_ticks}"
  puts "Num Lights: #{light_grid.num_lights} Lights On\n\n"
end

puts "\nPart 2: #{light_grid.num_lights} Lights On"
