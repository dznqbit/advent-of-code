#!/usr/bin/env ruby
# http://adventofcode.com/day/14
# 92611 too high
input = STDIN.read

class Reindeer
  # reindeer name
  attr_reader :name
  # km/s
  attr_reader :velocity
  # amount of time reindeer may hold velocity
  attr_reader :sprint_duration
  # amount of time needed between sprints
  attr_reader :cooldown_duration

  def initialize(name, velocity, sprint_duration, cooldown_duration)
    @name = name
    @velocity = velocity
    @sprint_duration = sprint_duration
    @cooldown_duration = cooldown_duration
  end

  def to_s
    "#{@name}"
  end

  def self.parse(s)
    re = /(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds/
    match = re.match(s)
    new(match[1], match[2].to_i, match[3].to_i, match[4].to_i)
  end
end

class ReindeerState
  attr_reader :position

  def initialize(reindeer)
    @reindeer = reindeer
    @position = 0
    @sprint_remaining = 0
    @cooldown_remaining = 0
  end

  def tick
    if @cooldown_remaining > 0
      # On cooldown.
      @cooldown_remaining -= 1
    else
      if @sprint_remaining == 0
        @sprint_remaining = @reindeer.sprint_duration
      end

      @sprint_remaining -= 1
      @position += @reindeer.velocity

      if @sprint_remaining == 0
        @cooldown_remaining = @reindeer.cooldown_duration
      end
    end
  end
end

class Race
  # Each entry = 1 second of race time
  attr_reader :frames

  def initialize(reindeer)
    @frames = []
    @reindeer = reindeer
    @reindeer_states = Hash.new { |h, r| h[r] = ReindeerState.new(r) }
    @reindeer.each { |r| @reindeer_states[r] }

    log_frame
  end

  def tick
    @reindeer_states.values.each(&:tick)

    log_frame
  end

  def frame
    @frames.length
  end

  def summary
    @reindeer.map do |r|
      s = @reindeer_states[r]
      "#{r} #{s.position}"
    end.join("\t")
  end

  private

  def log_frame
    @frames << Hash[*@reindeer_states.flat_map { |r,s| [r, s.position] }]
  end
end

reindeer = input.split("\n").map { |s| Reindeer.parse(s) }
race = Race.new(reindeer)
2503.times { race.tick }

current_frame = race.frames.last
winning_reindeer_and_position = current_frame.reduce([nil,0]) do |memo, (reindeer, position)|
  if position > memo[1]
    memo = [reindeer, position]
  end

  memo
end

puts "Part 1: #{winning_reindeer_and_position[1]}"

point_hash = Hash.new { |h, r| h[r] = 0 }
part_ii_points = race.frames.reduce(point_hash) do |memo, frame|
  max_position = frame.values.max

  # SKIP THE INITIAL STATE
  unless max_position == 0
    lead_reindeer = frame.find_all { |r, p| p == max_position }.map { |rs| rs[0] }
    lead_reindeer.each do |r|
      memo[r] += 1
    end
  end

  memo
end

# 1060 too high :(
puts "Part 2: #{part_ii_points.values.max}"
