# http://adventofcode.com/2021/day/2
from sys import __stdin__
from functools import reduce

input = __stdin__.read()

def parse_instruction(s):
  [direction, distance] = s.split(" ")
  return (direction, int(distance))

def next_position(position, instruction):
  (direction, distance) = instruction

  match direction:
    case "forward":
      return { "d": position["d"], "h": position["h"] + distance }
    case "down":
      return { "d": position["d"] + distance, "h": position["h"] }
    case "up":
      return { "d": position["d"] - distance, "h": position["h"] }
    case _:
      raise f"Unexpected direction \"{direction}\"" 

instructions = [parse_instruction(s) for s in input.splitlines()]
position = reduce(next_position, instructions, { "d": 0, "h": 0 })

print(f"Pt 1: {position['h'] * position['d']}")
