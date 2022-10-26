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

def next_position_pt2(position, instruction):
  (direction, distance) = instruction

  match direction:
    case "forward":
      return { "aim": position["aim"], "d": position["d"] + position["aim"] * distance, "h": position["h"] + distance }
    case "down":
      return { "aim": position["aim"] + distance, "d": position["d"], "h": position["h"] }
    case "up":
      return { "aim": position["aim"] - distance, "d": position["d"], "h": position["h"] }
    case _:
      raise f"Unexpected direction \"{direction}\"" 

position_pt2 = reduce(next_position_pt2, instructions, { "aim": 0, "d": 0, "h": 0 })
print(f"Pt 2: {position_pt2['h'] * position_pt2['d']}")
