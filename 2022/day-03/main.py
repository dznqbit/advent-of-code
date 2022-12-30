# http://adventofcode.com/2022/day/03
from sys import __stdin__
from math import floor
from functools import reduce

def split_rucksack(s):
  half = floor((len(s) / 2))
  return (s[:half], s[half:])

def common_item(a):
  i = reduce(lambda m, x: m & x, [set(s) for s in a if s])
  return list(i)[0]

def priority(x):
  o = ord(x)
  
  if o in range(97, 123):
    return o - 96
  elif o in range(65, 91):
    return o - 38
  
input = [s.strip() for s in __stdin__.readlines()]
rucksacks = [split_rucksack(s) for s in input]
common_items = [common_item(r) for r in rucksacks]
print("Pt1:", sum([priority(ci) for ci in common_items]))

groups = [input[i:i + 3] for i in range(0, len(input), 3)]
group_common_items = [common_item(g) for g in groups]
print("Pt2:", sum([priority(ci) for ci in group_common_items]))
