#!/usr/bin/env ruby
# http://adventofcode.com/day/5

input = STDIN.read

class Light
  module States
    ON = 1
    OFF = 0
  end

  def initialize
    @state = States::OFF
  end

  def turn_on
    @state = States::ON
  end

  def turn_off
    @state = States::OFF
  end

  def on?
    @state == States::ON
  end

  def toggle
    if on?
      turn_off
    else
      turn_on
    end
  end
end

class Instruction
  module Action
    ON = 'turn on'
    OFF = 'turn off'
    TOGGLE = 'toggle'

    ALL = [ON, OFF, TOGGLE]
  end

  def initialize(action, start_x, start_y, end_x, end_y)
    @action = action
    @start_x = start_x
    @start_y = start_y
    @end_x = end_x
    @end_y = end_y
  end

  def act(light)
    case @action
    when Action::ON       then light.turn_on
    when Action::OFF      then light.turn_off
    when Action::TOGGLE   then light.toggle
    end
  end

  def find_lights(lights)
    (@start_x..@end_x).flat_map do |x|
      lights[x][@start_y..@end_y]
    end
  end

  def to_s
    "#{@action} #{@start_x} #{@start_y} #{@end_x} #{@end_y}"
  end
end

instructions = []

input.split("\n").each_with_index do |s, i|
   match = /(turn\ off|turn\ on|toggle)\s(\d+,\d+)\sthrough\s(\d+,\d+)/.match(s)
   action, start_coord, end_coord = match[1], match[2], match[3]
   start_x, start_y = start_coord.split(',').map(&:to_i)
   end_x, end_y = end_coord.split(',').map(&:to_i)

   instructions << Instruction.new(action, start_x, start_y, end_x, end_y)
end

rows = 999
lights_per_row = 999

lights = Array.new(rows) { Array.new(lights_per_row) { Light.new } }

instructions.each do |ins|
  ins.find_lights(lights).each do |light|
    ins.act(light)
  end
end

turned_on_lights = lights.flat_map do |row|
  row.find_all(&:on?)
end

puts "Part 1: #{turned_on_lights.count} lights turned on"

class FancyLight
  attr_reader :brightness

  def initialize
    @brightness = 0
  end

  def turn_on
    @brightness += 1
  end

  def turn_off
    @brightness = [@brightness - 1, 0].max
  end

  def toggle
    @brightness += 2
  end
end

fancy_lights = Array.new(rows) { Array.new(lights_per_row) { FancyLight.new } }

instructions.each do |ins|
  ins.find_lights(fancy_lights).each do |light|
    ins.act(light)
  end
end

total_brightness = fancy_lights.flat_map { |a| a.map(&:brightness) }.reduce(0, :+)

puts "Part 2: #{total_brightness}"
