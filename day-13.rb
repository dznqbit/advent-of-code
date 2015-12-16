#!/usr/bin/env ruby
# http://adventofcode.com/day/13

input = STDIN.read

class Preference
  attr_reader :origin
  attr_reader :destination
  attr_reader :value

  def initialize(o, d, v)
    @origin = o
    @destination = d
    @value = v
  end

  def to_s
    "#{@origin} -> #{@destination} = #{@value}"
  end

  def self.parse(str)
    re = /(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)./
    match = re.match(str)

    origin = match[1]
    destination = match[4]
    sign =  case match[2]
            when 'gain' then 1
            when 'lose' then -1
            else raise
            end
    value = match[3].to_i * sign

    new(origin, destination, value)
  end
end

class Arrangement
  def initialize(people, preferences)
    @people = people
    @preferences = preferences
  end

  def total_change_in_happiness
    all_pairs.flat_map do |(a, b)|
      p_a_to_b = @preferences.find { |p| p.origin == a && p.destination == b }
      p_b_to_a = @preferences.find { |p| p.origin == b && p.destination == a }

      [
        p_a_to_b ? p_a_to_b.value : 0,
        p_b_to_a ? p_b_to_a.value : 0
      ]
    end.reduce(0, :+)
  end

  def all_pairs
    pairs = []
    num_people = @people.length

    if num_people > 1
      for i in 0...(num_people - 1) do
        pairs << [@people[i], @people[i+1]]
      end

      pairs << [@people[-1], @people[0]]
    end

    pairs
  end
end

def find_best_seating(people, preferences)
  people.permutation.reduce([0, nil]) do |memo, people|
    arrangement = Arrangement.new(people, preferences)
    total_change_in_happiness = arrangement.total_change_in_happiness

    if memo[0] < total_change_in_happiness
      memo = [total_change_in_happiness, people]
    end

    memo
  end
end

preferences = input.split("\n").map { |s| Preference.parse(s) }
people = preferences.flat_map { |p| [p.origin, p.destination] }.uniq

best_score_and_arrangement = find_best_seating(people, preferences)
puts "Part 1: #{best_score_and_arrangement[0]} #{best_score_and_arrangement[1]}"

people_including_myself = people + ['Me']

new_best_score_and_arrangement = find_best_seating(people_including_myself, preferences)
puts "Part 2: #{new_best_score_and_arrangement[0]} #{new_best_score_and_arrangement[1]}"
