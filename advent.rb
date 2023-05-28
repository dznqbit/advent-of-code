#!/usr/bin/env ruby

# advent.rb
#
# Run any solution with this handy tool.
#
# Examples:
#
#   % ./advent.rb 2018/day-7
#   % ./advent.rb 2016/1
#   % ./advent -t 2017/2
#

load './lib/advent-of-code.rb'
include AdventOfCode

options, args = ARGV.partition { |a| a.start_with?("-") }
use_test_input = options.include?("-t")

date = Date.parse(args[0])

exit_with_error("Couldn't parse Date from \"#{args[0]}\"") unless date

input_paths = date.input_paths(test: use_test_input)
relative_input_path = input_paths.find { |path| File.exists?(path) }

exit_with_error("Couldn't find input, checked: \n\t#{input_paths.join("\n\t")}") unless relative_input_path
absolute_input_path = File.expand_path(relative_input_path)

if File.directory?(project_path = date.project_path)
  language = detect_language(project_path)

  command = case(language)
  when :javascript then "cat #{absolute_input_path} | node main.js"
  when :python then "cat #{absolute_input_path} | python3 main.py"
  when :rust then "cat #{absolute_input_path} | cargo run --quiet"
  when :swift then "cat #{absolute_input_path} | swift run"
  when :typescript then "cat #{absolute_input_path} | npx ts-node main.ts"
  else exit_with_error("#{project_path}: Could not detect project type")
  end

  home_directory = Dir.pwd

  begin
    Dir.chdir(project_path)
    exec command
  ensure
    Dir.chdir(home_directory)
  end
else
  code_path = File.join(date.year, "#{date.day}.rb")
  exit_with_error("Could not find #{code_path}")  unless File.exists?(code_path)

  exec "cat #{absolute_input_path} | ./#{code_path}"
end
