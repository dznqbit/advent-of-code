#!/usr/bin/env ruby
# http://adventofcode.com/day/2

input = STDIN.read

Box = Struct.new(:length, :width, :height)

boxes = input.split("\n").map do |s|
  a = s.split('x').map(&:to_i)
  Box.new(a[0], a[1], a[2])
end

wrapping_paper_for_boxes = boxes.map do |box|
  # 2*l*w + 2*w*h + 2*h*l
  sides = [
    box.length * box.width,
    box.width * box.height,
    box.height * box.length
  ]

  smallest_side = sides.min
  perfect_box_area = sides.map { |s| s * 2 }.reduce(0, :+)

  smallest_side + perfect_box_area
end

puts "Part 1: #{wrapping_paper_for_boxes.reduce(0, :+)}"

ribbon_lengths_for_boxes = boxes.map do |box|
  dimensions = [box.length, box.width, box.height]

  # The ribbon required to wrap a present is the shortest distance around its sides,
  # or the smallest perimeter of any one face.
  smallest_two_dimensions = dimensions.sort[0...2]
  wrap_ribbon = smallest_two_dimensions.map { |d| d * 2 }.reduce(0, :+)

  # Each present also requires a bow made out of ribbon as well;
  # equal to the cubic feet of volume of the present.
  bow_ribbon = dimensions.reduce(:*)


  wrap_ribbon + bow_ribbon
end

puts "Part 2: #{ribbon_lengths_for_boxes.reduce(0, :+)}"
