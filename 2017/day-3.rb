#!/usr/bin/env ruby
# Advent of Code, Day 3
# https://adventofcode.com/2017/day/3
# https://github.com/dznqbit/advent-of-code

# Spiral is allocated like so
#
# 65  64  63  62  61  60  59  58  57
# 66  37  36  35  34  33  32  31  56
# 67  38  17  16  15  14  13  30  55
# 68  39  18   5   4   3  12  29  54
# 69  40  19   6   1   2  11  28  53
# 70  41  20   7   8   9  10  27  52
# 71  42  21  22  23  24  25  26  51
# 72  43  44  45  46  47  48  49  50
# 73  74  75  76  77  78  79  80  81

class SpiralCoordinate
  class << self
    def origin
      @origin ||= new(1)
    end

    def fcrt(c)
      "(#{c[0].to_s.rjust(4)}, #{c[1].to_s.rjust(4)})"
    end

    # The first number on dimension @d. brc(n - 1) + 1
    def first_of_dimension(d)
      case
      when d  < 0 then raise ArgumentError.new("Bad Dimension: #{d}")
      when d == 0 then 1
      else (0..(d-1)).reduce(2) { |m, v| m += v * 8 }
      end
    end

    # The last number on dimension @d. brc(n)
    def last_of_dimension(d)
      (0..d).reduce(1) { |m, v| m += v * 8 }
    end
  end

  attr_reader :v

  def initialize(v)
    raise ArgumentError.new("Invalid Address #{v}") if v.to_i < 1

    @v = v.to_i
  end

  def to_s
    "SC<v=#{v} d=#{dimension} crt=(#{to_cartesian.join(', ')})>"
  end

  # @return Array[x,y] cartesian coordinates
  # Ex: SpiralCoordinate.origin.to_cartesian => [0, 0]
  def to_cartesian
    return [0, 0] if v == 1

    # From reference point
    spiral_coords = self.class.first_of_dimension(dimension)

    steps = [
      [ 0,  1], # up
      [-1,  0], # left
      [ 0, -1], # down
      [ 1,  0]  # right
    ].flat_map.with_index do |direction, i|
      steps_to_take = steps_per_side + (i == 0 ? -1 : 0)
      [direction] * steps_to_take
    end.lazy

    # start from first of dimension & go from there
    cartesian_coords = if dimension == 0
      [0, 0]
    else
      [dimension, -(dimension - 1)]
    end

    while spiral_coords < v
      step = steps.next

      cartesian_coords[0] += step[0]
      cartesian_coords[1] += step[1]

      spiral_coords += 1
    end

    cartesian_coords
  end

  private

  def steps_per_side
    dimension * 2
  end

  # Return dimension that we live on.
  def dimension
    @dimension ||= begin
      d = 0

      while v > self.class.first_of_dimension(d) && v > self.class.last_of_dimension(d)
        d += 1
      end

      d
    end
  end

end

# Test
cartesians = Hash.new { |h, k| h[k] = [] }

for n in 1..26
  sc = SpiralCoordinate.new(n)
  cartesians[sc.to_cartesian] << sc
end

lowest_x, highest_x  = cartesians.keys.map { |crt| crt[0] }.minmax
lowest_y, highest_y  = cartesians.keys.map { |crt| crt[1] }.minmax

def draw_spiral(xmin, xmax, ymin, ymax)
  for y in ymax.downto(ymin)
    for x in xmin..xmax
      v = cartesians[[x, y]].map(&:v)
      print "#{v.join(', ')}".rjust(5)
    end

    puts "\n"
  end
end

def draw_coordinates(xmin, xmax, ymin, ymax)
  for y in ymax.downto(ymin)
    for x in xmin..xmax
      v = cartesians[[x, y]].map(&:v)
      print "(#{x},#{y})".rjust(10)
    end
  end

  puts "\n"
end

def part1(input)
  sc = SpiralCoordinate.new(input)
  x, y = sc.to_cartesian
  manhattan_distance = x.abs + y.abs
end

def part2(input)
  # tape[cartesian] -> v
  tape = {
    [0, 0] => 1
  }

  p = 1
  n = 1

  while n <= input
    p += 1

    sc = SpiralCoordinate.new(p)

    neighbor_cartesian_dirs = [-1, 0, 1].flat_map do |x|
      [-1, 0, 1].map { |y| [x, y] }
    end.reject { |x| x == [0, 0] }

    neighbor_cartesian_coords = neighbor_cartesian_dirs.map do |crt_dir|
      crt = sc.to_cartesian

      [
        crt[0] + crt_dir[0],
        crt[-1] + crt_dir[-1]
      ]
    end

    neighbor_sum = neighbor_cartesian_coords.
      map { |ncrt| tape[ncrt] }.
      compact.
      reduce(:+) || 0

    tape[sc.to_cartesian] = neighbor_sum

    n = neighbor_sum
  end

  n
end

input = STDIN.readlines.first.strip.to_i

puts "Pt 1: #{part1(input)}"
puts "Pt 2: #{part2(input)}"
