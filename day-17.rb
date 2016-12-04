#!/usr/bin/env ruby
# http://adventofcode.com/day/17

input = STDIN.read

require 'logger'
@logger = Logger.new(STDOUT)

liters = 150
container_liters = input.split("\n").map(&:strip).map(&:to_i)

# Return an Array of Arrays whose sum matches +volume+
# All successful combinations of +containers+
def combinations(
  containers,     # Containers to try
  volume          # Remaining volume to satisfy
)
  if containers.empty?
    []
  elsif volume < 0
    []
  else
    (0...containers.length).flat_map do |i|
      head = containers[i]
      tail = containers[(i+1)..-1]

      remaining_volume = volume - head

      if remaining_volume == 0
        [[head]]
      else
        combinations(tail, remaining_volume).map { |c| c.insert(0, head) }
      end
    end
  end
end

all_combos = combinations(container_liters , liters)

#puts "Containers:\t#{container_liters.join(', ')}"
#puts "To Fill:\t#{liters}"
puts "Part 1: #{all_combos.count} Combos"

# puts "#{all_combos.map(&:to_s).join("\n\t\t")}"
all_combo_lengths = all_combos.map(&:length).sort
grouped_combos = all_combo_lengths.group_by { |i| i }
min_group = grouped_combos.first
puts min_group.inspect
puts "Part 2: Min containers #{min_group.first}, #{min_group[1].count} different ways"
