#!/usr/bin/env ruby
# http://adventofcode.com/day/19

input = STDIN.read
lines = input.split("\n").map(&:strip)
require 'logger'

class Replacer
  Replacement = Struct.new(
    # The original string
    :source,
    # The substring to be substituted
    :target,
    # The replacement
    :replacement,
    # The zero-based index of the target
    :target_index,
    # The new string with replacement performed
    :result
  )

  def initialize(replacement_array)
    @replacements = Hash.new  { |h, k| h[k] = [] }
    replacement_array.each    { |i, o| @replacements[i] << o }
  end

  def replacements(str)
    total_replacements = @replacements.keys.flat_map do |key|
      key_length  = key.length
      key_indexes = indexes(str, key)

      key_indexes.flat_map do |key_index|
        @replacements[key].map do |replacement|
          replaced_string = [
            str[0...key_index],
            replacement,
            str[(key_index + key_length)..-1]
          ].join('')

          Replacement.new(
            str,
            key,
            replacement,
            key_index,
            replaced_string
          )
        end
      end
    end

    # Reject duplicate substitutions
    total_replacements.uniq(&:result)
  end

  private

  def indexes(str, sub)
    index = -1
    indexes = []

    while index = str.index(sub, index + 1)
      indexes << index
    end

    indexes
  end
end

replacement_pairs = lines[0..-3].map { |s| s.scan(/\w+/) }
starting_molecule = lines[-1]

replacer = Replacer.new(replacement_pairs)
replacements = replacer.replacements(starting_molecule)

puts "Part 1: #{replacements.length} total substitutions"
