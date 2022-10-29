# http://adventofcode.com/2021/day/5
from functools import reduce
from sys import __stdin__

input = __stdin__.read()

instructions = [
  tuple(map(lambda i: tuple(int(s) for s in i.split(",")), s.split(" -> "))) 
  for s in input.splitlines()
]

def print_ocean_map(ocean_map):
  for line in ocean_map:
    print("".join("." if s == 0 else str(s) for s in line))

def calculate_part_one(instructions):
  max_x = max(list(cx for i in instructions for (cx, _) in list(i)))
  max_y = max(list(cy for i in instructions for (_, cy) in list(i)))
  ocean_map = [[0 for x in range(max_x + 1)] for y in range(max_y + 1)]

  for instruction in instructions:
    ((sx, sy), (fx, fy)) = instruction
    
    if sx != fx and sy != fy:
      continue

    if sx == fx:
      step = 1 if sy < fy else -1
      for y in range(sy, fy + step, step):
        ocean_map[y][sx] += 1

    if sy == fy:
      step = 1 if sx < fx else -1
      for x in range(sx, fx + step, step):
        ocean_map[sy][x] += 1
  
  return len([v for line in ocean_map for v in line if v > 1])

print("Pt 1:", calculate_part_one(instructions))

def calculate_part_two(instructions):
  max_x = max(list(cx for i in instructions for (cx, _) in list(i)))
  max_y = max(list(cy for i in instructions for (_, cy) in list(i)))
  ocean_map = [[0 for x in range(max_x + 1)] for y in range(max_y + 1)]

  for instruction in instructions:
    ((sx, sy), (fx, fy)) = instruction
    y_step = 1 if sy < fy else -1
    x_step = 1 if sx < fx else -1

    if sx != fx and sy != fy:
      for i in range(max([abs(fx - sx), abs(fy - sy)]) + 1):
        x = sx + x_step * i
        y = sy + y_step * i
        
        ocean_map[y][x] += 1

    if sx == fx:
      for y in range(sy, fy + y_step, y_step):
        ocean_map[y][sx] += 1

    if sy == fy:
      for x in range(sx, fx + x_step, x_step):
        ocean_map[sy][x] += 1
  
  return len([v for line in ocean_map for v in line if v > 1])

print("Pt 2:", calculate_part_two(instructions))
