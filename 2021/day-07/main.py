# http://adventofcode.com/2021/day/7
from functools import reduce
from sys import __stdin__
from statistics import median

input = __stdin__.read()
crab_positions = [int(x) for x in input.strip().split(",")]

def calc_fuel_cost(position, crab_positions):
  return sum([abs(position - p) for p in crab_positions])

def positions_to_fuel_costs(crab_positions):
  position_to_fuel_costs = {}

  min_position = min(crab_positions)
  max_position = max(crab_positions)

  for position in range(min_position, max_position):
    position_to_fuel_costs[position] = calc_fuel_cost(position, crab_positions)

  return position_to_fuel_costs

p2fcs = positions_to_fuel_costs(crab_positions)
mfc = reduce(lambda m, pfc: pfc if m[1] > pfc[1] else m, p2fcs.items())

print("Pt 1:", mfc[1])
