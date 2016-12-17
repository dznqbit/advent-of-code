#!/usr/bin/env ruby

def exit_with_error(err); STDERR.puts(err); exit; end

arg0 = ARGV[0]

if arg0.nil?
  STDERR.puts "Usage: #{$0} [<year_id>/]<day_id>"
  exit
end

year, day_id = if arg0.include?('/')
  arg0.split('/')
else
  # If year doesn't exist assume current year
  [Time.now.year.to_s, arg0]
end

# Cleanup so you can call with either '7' or 'day-7'
day = "day-#{day_id.gsub('day-','')}"

# Check for directory.
if File.directory?(day_dir_path=File.join(year, day))
  unless File.exists?(File.join(day_dir_path, 'src', 'main.rs'))
     exit_with_error("Could not find src/main.rs inside #{day_dir_path} !")
  end

  home_directory = Dir.pwd

  begin
    Dir.chdir(day_dir_path)
    input_file = "#{day}.input"
    exit_with_error("Could not find #{day_dir_path}/#{input_file}") unless File.exists?(input_file)
    exec "cat #{input_file} | cargo run"
  ensure
    Dir.chdir(home_directory)
  end
else
  input_path = File.join(year, "#{day}.input")
  code_path = File.join(year, "#{day}.rb")

  exit_with_error("Could not find #{input_path}") unless File.exists?(input_path)
  exit_with_error("Could not find #{code_path}")  unless File.exists?(code_path)

  exec "cat #{input_path} | ./#{code_path}"
end
