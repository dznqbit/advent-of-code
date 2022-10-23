module AdventOfCode
  Languages = %i[ruby rust swift python]

  Date = Struct.new(:year, :day) do
    # Parse incoming date string
    #
    # Examples:
    #   2018/day-7
    #   2016/1
    #
    # @param String str
    # @return nil, Date
    def self.parse(str)
      return nil unless str
      year, day = str.split('/').map { |s| s.gsub('day-','') }
      return nil unless year =~ /^\d{4}$/ && day =~ /^\d+$/
      Date.new(year, day)
    end

    # List of potential input file locations.
    #
    # Input files may exist in following locations:
    #   ./2017/day-1.input
    #   ./2017/day-1.txt
    #   ./2017/day-1/day-1.input
    #   ./2017/day-1/day-1.txt
    #
    # Sample files have -sample prepended before the extension:
    #
    #   ./2017/day-1-sample.input
    #   ./2017/day-2/day-2-sample.txt
    #
    # @params Boolean test
    # @return [String]
    def input_paths(test:)
      extensions = %w(input txt)
      suffix = test ? '-sample' : ''
      days = ["day-#{day}", sprintf("day-%02i", day)]

      filenames = extensions.
        flat_map { |ext| days.map { |day| "#{day}#{suffix}.#{ext}" } }

      directories = days.flat_map { |day| [year, File.join(year, day)] }
      directories
        .flat_map { |d| filenames.map { |f| [d, f] } }
        .map { |(d, fn)| File.join(d, fn) }
    end

    # File path at which the project will exist. Prefer zero-padded strings
    #
    # @return nil, String
    def project_path
      paths = [sprintf("day-%02i", day), "day-#{day}", ].map { |day| File.join(year, day) }
      existing_path = paths.find { |dir| !Dir[dir].empty? }
      existing_path || paths.first
    end

    # URL to problem page
    #
    # @return String
    def advent_of_code_url
      "http://adventofcode.com/#{year}/day/#{day}"
    end
  end

  # Convenience for CLI
  def exit_with_error(err)
    STDERR.puts(err)
    exit
  end

  # Scan directory for common project files
  # @param String d
  # @return nil, Symbol
  def detect_language(d)
    case
    when File.exists?(File.join(d, 'src', 'main.rs')) then :rust
    when File.exists?(File.join(d, 'Package.swift')) then :swift
    when File.exists?(File.join(d, 'main.py')) then :python
    else nil
    end
  end

  # Return a proc to build your language project.
  def factory(language)
    case language
    when :python
      Proc.new do |project_path, date|
        FileUtils.cd(project_path)
        python_boilerplate = <<END
# #{date.advent_of_code_url}
from sys import __stdin__

input = __stdin__.read()
print(input)
END
        File.open("main.py", 'w+') { |f| f.write(python_boilerplate) }
      end

    when :ruby
      Proc.new do |project_path, date|
        raise "Not Implemented!"
      end

    when :rust
      Proc.new do |project_path, date|
        raise "Not Implemented!"
      end

    when :swift
      Proc.new do |project_path, date|
        FileUtils.cd(project_path)
        puts `swift package init --type executable`

        # Replace main.swift with boilerplate main
        main_path = "Sources/#{File.split(project_path).last}/main.swift"
        swift_boilerplate = <<END
// #{date.advent_of_code_url}

var lines: [String] = []
while let line = readLine() {
  lines.append(line)
}

for line in lines {
  print(line)
}

print("Pt. 1: {}", "???")
print("Pt. 2: {}", "???")
END

        File.open(main_path, 'w+') { |f| f.write(swift_boilerplate) }
      end

    end
  end
end
