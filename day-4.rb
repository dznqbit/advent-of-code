#!/usr/bin/env ruby
# http://adventofcode.com/day/4

input = STDIN.read

# find MD5 hashes which, in hexadecimal, start with at least five zeroes
# The input to the MD5 hash is secret key followed by a number in decimal.
# find Santa the lowest positive number (no leading zeroes: 1, 2, 3, ...) that produces such a hash

require 'ruby-progressbar'

require 'digest'

secret_key = input.chomp

def find_first_md5(secret_key, prefix)
  progress = ProgressBar.create total: nil, format: "%t %c"
  smallest_number = nil
  current_number = 0
  value = nil

  while smallest_number.nil?
    check = "#{secret_key}#{current_number}"
    value = Digest::MD5.hexdigest(check)

    if value.start_with?(prefix)
      smallest_number = current_number
    end

    current_number += 1
    progress.increment
  end

  # Progressbar hates my terminal
  puts ""

  smallest_number
end

smallest_number = find_first_md5(secret_key, '00000')
puts "Part 1: #{smallest_number}"

smallest_number = find_first_md5(secret_key, '000000')
puts "Part 2: #{smallest_number}"
