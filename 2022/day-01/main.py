# 2022/day-01/main.py
from sys import __stdin__
from functools import reduce
from itertools import pairwise

input = __stdin__.read()
depth_readings = [int(x) for x in input.splitlines()]
depth_reading_increases = filter(lambda x: x[0] < x[1], pairwise(depth_readings))
count_of_depth_reading_increases = len(list(depth_reading_increases))

print(f"Pt 1: {count_of_depth_reading_increases}")
