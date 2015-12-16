#!/usr/bin/env ruby
# http://adventofcode.com/day/11

input = STDIN.read

class Validator
  def initialize(s)
    @s = s
  end

  def valid?
    [
      includes_straight?,
      excludes_weird_letters?,
      two_different_non_overlapping_pairs?
    ].all?
  end

  def includes_straight?
    for i in 0...(@s.length - 2)
      c1, c2, c3 = @s[i..i+2].split('')

      next if %(y z).include?(c1)

      is_straight = c1.next == c2 && c2.next == c3

      return true if is_straight
    end

    false
  end

  def excludes_weird_letters?
    (@s =~ /[iol]/).nil?
  end

  def two_different_non_overlapping_pairs?
    @s.scan(/([a-z])\1/).length > 1
  end
end

def increment(password)
  next_password = password.next
  next_password.next! while !Validator.new(next_password).valid?
  next_password
end

def v?(s); Validator.new(s).valid?; end
def debug(s)
  v = Validator.new(s)
  puts "#{s}: str? #{v.includes_straight?} ex_weird? #{v.excludes_weird_letters?} two_pair? #{v.two_different_non_overlapping_pairs?}"
end

#['hijklmmn', 'abbceffg', 'abbcegjk'].each { |s| puts debug(s) }

#puts "increment \"abcdefgh\": \"#{increment('abcdefgh')}\""
#puts "increment \"ghijklmn\": \"#{increment('ghijklmn')}\""

current_password = input.chomp
new_password = increment(current_password)

puts "Part 1: #{new_password}"

new_password = increment(new_password)
puts "Part 2: #{new_password}"
