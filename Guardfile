# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# https://github.com/guard/guard/wiki/Create-a-guard
require 'guard/plugin'

# the double-colons below are *required* for inline Guards!!!

module ::Guard
  class AdventOfCode < Plugin
    include ::Guard::UI

    def initialize(options = {})
      opts = options.dup
      super(opts) # important to call + avoid passing options Guard doesn't understand
    end

    def run_all
      for year in 2015..(Time.now.year) do
        for day in 1..31 do
          run_advent(year, day)
        end
      end
    end

    def run_on_modifications(paths)
      for path in paths
        md = /(\d{4})\/day-(\d+)/.match(path)
        year, day = md[1..2]
        run_advent year, day
      end
    end

    private

    def run_advent(year, day)
      test = true
      output = `./advent.rb #{test ? "-t" : ""} #{year}/#{day}`
      # logger.info "#{year}/#{day} START #{test ? "TEST" : ""}"
      output.split("\n").each { |s| logger.info "#{year}/#{day} #{s}\n" }
    end

    def logger
      ::Guard::UI.logger
    end
  end
end


guard :advent_of_code do
  watch(/^\d{4}\/day-\d+\/src\/(.*)\.rs$/)
  watch(/^\d{4}\/day-\d+\/Sources\/(.*)\.swift$/)
  watch(/^\d{4}\/day-\d+\.rb$/)
end
