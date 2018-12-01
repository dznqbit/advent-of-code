#!/usr/bin/env ruby

# advent.rb
#
# Run any solution with this handy tool.
#
# Source can be a bit flexible:
#
#   ./2015/day-1.rb
#   ./2016/day-1/(rust project)
#   ./2018/day-1/(java project)
#
# Input files:
#
#   ./2018/day-n.input
#   ./2018/day-n-sample.input
#
# Examples:
#
#   % ./advent.rb 2018/day-7
#   % ./advent.rb 2016/1
#   % ./advent -t 2017/2
#

def exit_with_error(err); STDERR.puts(err); exit; end

def input_path(year, day, test = false)
  [
    year, # ./2017/day-1.input
    File.join(year, day) # ./2016/day-1/day-1.input
  ].map do |directory|
    filename = test ? "#{day}-sample.input" : "#{day}.input"
    File.join(directory, filename)
  end.reduce do |m, path|
    existing_path =File.exists?(path) ? path : nil
    m || existing_path
  end
end

options, args = ARGV.partition { |a| a.start_with?("-") }

year, day_id = (args[0] || '').split('/')
use_test_input = options.include?("-t")

unless year && day_id
  STDERR.puts "Usage: #{$0} <year_id>/<day_id>"
  exit
end

# Cleanup so you can call with either '7' or 'day-7'
day = "day-#{day_id.gsub('day-','')}"

relative_input_path = input_path(year, day, use_test_input)

unless relative_input_path
  exit_with_error("Couldn't find input, checked: \n\t#{input_paths.join("\n\t")}")
end

absolute_input_path = File.expand_path(relative_input_path)

if File.directory?(day_dir_path=File.join(year, day))
  rust_project = File.exists?(File.join(day_dir_path, 'src', 'main.rs'))
  swift_project = File.exists?(File.join(day_dir_path, 'Package.swift'))

  # This command will be run from context of day_dir_path
  local_command = case
  when rust_project   then "cat #{absolute_input_path} | cargo run --quiet"
  when swift_project  then "cat #{absolute_input_path} | (swift run 2> /dev/null)"
  else
     exit_with_error("#{day_dir_path}: Could not detect project type!")
  end

  home_directory = Dir.pwd

  begin
    Dir.chdir(day_dir_path)
    exec local_command
  ensure
    Dir.chdir(home_directory)
  end
else
  code_path = File.join(year, "#{day}.rb")
  exit_with_error("Could not find #{code_path}")  unless File.exists?(code_path)

  exec "cat #{absolute_input_path} | ./#{code_path}"
end
