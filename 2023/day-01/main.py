# http://adventofcode.com/2023/day/01
from sys import __stdin__
import re

input = __stdin__.read()

def cv1(s):
  ms = re.findall(r'\d', s)
  return (int(ms[0]) * 10) + int(ms[-1])

pt1 = sum([cv1(l) for l in input.splitlines()])
print(f"Pt 1: {pt1}")

def pn(s):
  if re.match('\d', s):
    return int(s)

  return {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9
  }[s]

def cv2(s):
  fms = re.findall(r'\d|one|two|three|four|five|six|seven|eight|nine', s)
  lms = re.findall(r'\d|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin', "".join(reversed(s)))
  return (pn(fms[0]) * 10) + pn("".join(reversed(lms[0])))

pt2 = sum([cv2(l) for l in input.splitlines()])
print(f"Pt 2: {pt2}")
