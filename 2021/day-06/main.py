# http://adventofcode.com/2021/day/6
from sys import __stdin__

input = __stdin__.read()
numbers = [int(x) for x in input.strip().split(",")]

def pass_day(fishes):
  return [6 if fish == 0 else fish - 1 for fish in fishes] + [8 for fish in fishes if fish == 0]

pt1_fishes = [n for n in numbers]

for n in range(80):
  pt1_fishes = pass_day(pt1_fishes)
  # print(f"Day {str(1 + n).rjust(2)}", ",".join(str(f) for f in fishes))

print("Pt 1:", len(pt1_fishes))

pt2_fishes = [n for n in numbers]

for n in range(256):
  pt2_fishes = pass_day(pt2_fishes)
