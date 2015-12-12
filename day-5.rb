#!/usr/bin/env ruby
# http://adventofcode.com/day/5

input = STDIN.read

class StringValidator
  def initialize(s)
    @s = s
  end

  def is_nice?
    contains_at_least_3_vowels? &&
    contains_at_least_one_repetition? &&
    excludes_naughty_strings?
  end

  # It contains at least three vowels (aeiou only), like aei, xazegov, or aeiouaeiouaeiou.
  def contains_at_least_3_vowels?
    chars.find_all { |c| %w(a o e i u).include?(c) }.count >= 3
  end

  # It contains at least one letter that appears twice in a row, like xx, abcdde (dd), or aabbccdd (aa, bb, cc, or dd).
  def contains_at_least_one_repetition?
    /([a-zA-Z])(\1)/ =~ @s
  end

  # It does not contain the strings ab, cd, pq, or xy, even if they are part of one of the other requirements.
  def excludes_naughty_strings?
    (/(ab|cd|pq|xy)/ =~ @s).nil?
  end

  def chars
    @s.chars
  end
end

strings = input.split("\n").map(&:chomp)

nice_strings = strings.find_all { |s| StringValidator.new(s).is_nice? }
puts "Part 1: #{nice_strings.count} nice strings"

class StringValidator
  def is_nice?
    contains_double_pair? && contains_saddle_pair?
  end

  # It contains a pair of any two letters that appears at least twice in the string without overlapping, like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps).
  def contains_double_pair?
    /([a-zA-Z]{2}).*\1/ =~ @s
  end

  # It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.
  def contains_saddle_pair?
    /([a-zA-Z]).\1/ =~ @s
  end
end

nice_strings = strings.find_all { |s| StringValidator.new(s).is_nice? }
puts "Part 2: #{nice_strings.count} nice strings"
