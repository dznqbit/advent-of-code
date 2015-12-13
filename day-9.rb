#!/usr/bin/env ruby
# http://adventofcode.com/day/9

require 'ruby-progressbar'

input = STDIN.read

def parse(distance_str)
  m = /(\w+)\ to\ (\w+)\ =\ (\d+)/.match(distance_str)
  [m[1], m[2], m[3].to_i]
end

class City
  def initialize(name)
    @name = name
    @links = {}
  end

  def to_s
    @name
  end

  def add_link(city, distance)
    @links[city] = distance
  end

  def linked_cities
    @links.keys
  end

  def distance_to_city(city)
    @links[city]
  end
end

class CityDistances
  def initialize
    @cities = Hash.new { |h, city_name| h[city_name] = City.new(city_name) }
  end

  def [](origin, destination)
    @cities[origin].distance_to_city(destination)
  end

  def []=(origin, destination, distance)
    origin_city = @cities[origin]
    destination_city = @cities[destination]

    origin_city.add_link(destination, distance)
    destination_city.add_link(origin, distance)

    distance
  end

  def cities
    @cities.keys
  end
end

hash_to_hash = Hash.new { |h, k| h[k] = {} }
city_distances = CityDistances.new

input.split("\n").map do |city_distance_str|
  origin, destination, distance = parse(city_distance_str)
  city_distances[origin, destination] = distance
end

# Now that city distances are loaded, we can start working.
all_cities = city_distances.cities

routes_and_distances = all_cities.permutation.flat_map do |route|
  distances = []

  for i in 0...(route.length - 1) do
    origin = route[i]
    destination = route[i+1]

    distance = city_distances[origin, destination]
    distances << distance
  end

  [
    route,
    if distances.include?(nil)
      nil
    else
      distances.reduce(0, :+)
    end
  ]
end

routes_to_distances = Hash[*routes_and_distances].reject { |k,v| v.nil? }
best_route_and_distance = routes_to_distances.reduce([nil, nil]) do |memo, (route, route_distance)|
  memo_route, memo_distance = memo

  if memo_distance.nil? || memo_distance > route_distance
    memo[0] = route
    memo[1] = route_distance
  end

  memo
end

# routes_to_distances.each { |k,v| puts "#{v}: #{k.join(', ')}" }

puts "Part 1: #{best_route_and_distance[1]}"

worst_route_and_distance = routes_to_distances.reduce([nil, nil]) do |memo, (route, route_distance)|
  memo_route, memo_distance = memo

  if memo_distance.nil? || memo_distance < route_distance
    memo[0] = route
    memo[1] = route_distance
  end

  memo
end

puts "Part 2: #{worst_route_and_distance[1]}"
