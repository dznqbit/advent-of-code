#!/usr/bin/env ruby

# new.rb
#
# Create a new solution with the boilerplate of your choice.
#
# Examples:
#
#   % ./new.rb swift 2018/7

require 'fileutils'
load './lib/advent-of-code.rb'
include AdventOfCode

language_arg = ARGV[0]&.intern
language = Languages.find { |l| l == language_arg }

unless language
  exit_with_error "Could not create project for language \"#{language_arg}\"." \
    " Available languages: #{Languages.map(&:to_s).join(', ')}"
end

date = Date.parse(ARGV[1])
exit_with_error "Could not parse date from \"#{ARGV[1]}\"" unless date

project_path = date.project_path
exit_with_error "#{project_path} already exists, cannot overwrite" if File.directory?(project_path)

factory = factory(language)
exit_with_error "Could not build #{language} project" unless factory

home_path = Dir.pwd

begin
  puts "Creating #{language} at #{project_path}"
  FileUtils.mkdir(project_path)
  factory.call(project_path, date)
rescue Exception => e
  FileUtils.cd home_path
  FileUtils.rm_rf(project_path)
  raise e
ensure
  FileUtils.cd home_path
end
