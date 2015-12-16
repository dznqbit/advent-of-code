#!/usr/bin/env ruby
# http://adventofcode.com/day/12

input = STDIN.read

require 'json'

class HashPlumber
  def initialize(hash)
    @hash = hash
  end

  def find_all_number_values(i = nil)
    o = i || @hash

    case o
    when String
    when Fixnum
      o
    when Array
      o.flat_map { |v| find_all_number_values(v) }.compact
    when Hash
      chew_hash(o)
    else
      raise "Don't know class #{o.class}"
    end
  end

  def chew_hash(o)
    o.flat_map { |_, v| find_all_number_values(v) }.compact
  end
end

big_fat_hash = JSON.parse(input)

plumber = HashPlumber.new(big_fat_hash)
all_number_values = plumber.find_all_number_values
puts "Part 1: #{all_number_values.reduce(0, :+)}"

class RedHashPlumber < HashPlumber
  def chew_hash(o)
    if o.values.include?('red')
      []
    else
      super(o)
    end
  end
end

red_plumber = RedHashPlumber.new(big_fat_hash)
red_number_values = red_plumber.find_all_number_values
puts "Part 2: #{red_number_values.reduce(0, :+)}"
