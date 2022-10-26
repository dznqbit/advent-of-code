# http://adventofcode.com/2021/day/1
from curses import window
from sys import __stdin__
from functools import reduce
from itertools import pairwise, islice

input = __stdin__.read()
depth_readings = [int(x) for x in input.splitlines()]
depth_reading_increases = filter(lambda x: x[0] < x[1], pairwise(depth_readings))
count_of_depth_reading_increases = len(list(depth_reading_increases))
print(f"Pt 1: {count_of_depth_reading_increases}")

windowed_depth_readings = [sum(islice(depth_readings, i, i + 3)) for i in range(0, len(depth_readings) - 2)]
windowed_depth_reading_increases = len(list(filter(lambda x: x[0] < x[1], pairwise(windowed_depth_readings))))
print(f"Pt 2: {windowed_depth_reading_increases}")
