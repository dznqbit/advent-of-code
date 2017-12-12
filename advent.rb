#!/usr/bin/env ruby

def exit_with_error(err); STDERR.puts(err); exit; end

options, args = ARGV.partition { |a| a.start_with?("-") }

arg0 = args[0]
test = options.include?("-t")

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

# Build Input Path
input_filename = test ? "#{day}-sample.input" : "#{day}.input"

input_paths = [
  # Typically the input file will be child of the year directory.
  File.join(year, input_filename),

  # Legacy Rust implementations (2016) put sample input inside year/day directories.
  File.join(year, day, input_filename)
]

unless relative_input_path = input_paths.find { |fp| File.exists?(fp) }
  exit_with_error("Couldn't find input, checked: \n\t#{input_paths.join("\n\t")}")
end

absolute_input_path = File.expand_path(relative_input_path)

if File.directory?(day_dir_path=File.join(year, day))
  unless File.exists?(File.join(day_dir_path, 'src', 'main.rs'))
     exit_with_error("Could not find src/main.rs inside #{day_dir_path} !")
  end

  home_directory = Dir.pwd

  begin
    Dir.chdir(day_dir_path)
    exec "cat #{absolute_input_path} | cargo run --quiet"
  ensure
    Dir.chdir(home_directory)
  end
else
  code_path = File.join(year, "#{day}.rb")
  exit_with_error("Could not find #{code_path}")  unless File.exists?(code_path)

  exec "cat #{absolute_input_path} | ./#{code_path}"
end
