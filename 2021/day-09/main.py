# http://adventofcode.com/2021/day/9
from sys import __stdin__

input = __stdin__.read()
height_map = [list(int(s) for s in line) for line in input.splitlines()]

class SmokeDetector:
  def __init__(self, height_map):
    self.height_map = height_map
    self.bounds = (len(height_map[0]), len(height_map))

  def value(self, coordinates):
    (x, y) = coordinates
    return self.height_map[y][x]

  def all_coordinates(self):
    return [(x, y) for y in range(self.bounds[1]) for x in range(self.bounds[0])]

  def neighboring_coordinates(self, coordinates):
    (x, y) = coordinates
    return [
      c
      for c in [(x, y - 1), (x + 1, y), (x, y + 1), (x - 1, y)] 
      if c[0] in range(0, self.bounds[0]) and c[1] in range(0, self.bounds[1])
    ]

  def is_low_point(self, coordinates):
    v = self.value(coordinates)
    neighbors = self.neighboring_coordinates(coordinates)
    higher_neighbors = [nc for nc in neighbors if self.value(nc) > v]
    return len(neighbors) == len(higher_neighbors)

smoke_detector = SmokeDetector(height_map)

coordinates = smoke_detector.all_coordinates()
low_point_coordinates = [c for c in coordinates if smoke_detector.is_low_point(c)]
risk_levels = [smoke_detector.value(lpc) + 1 for lpc in low_point_coordinates]

print("Pt 1:", sum(risk_levels))
