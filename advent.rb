#!/usr/bin/env ruby

day_id = ARGV[0]

if day_id.nil?
  STDERR.puts "Usage: #{$0} <day_id>\n\n" \
              "\tEx: #{$0} 7"
  exit
end

# Cleanup so you can call with either '7' or 'day-7'
prefix = "day-#{day_id.gsub('day-','')}"

input_path = "#{prefix}.input"
code_path = "#{prefix}.rb"

unless File.exists?(input_path)
  STDERR.puts "Could not find #{input_path}"
  exit
end

unless File.exists?(code_path)
  STDERR.puts "Could not find #{code_path}"
  exit
end

print `cat #{input_path} | ./#{code_path}`
