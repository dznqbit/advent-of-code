# http://adventofcode.com/2021/day/11
from sys import __stdin__

input = __stdin__.read()
octopi = [list(int(s) for s in line) for line in input.splitlines()]

class Grid:
  def __init__(self, grid):
    self.grid = grid
    self.bounds = (len(grid[0]), len(grid))

  def __repr__(self):
    return "\n".join(["".join(str(i) for i in line) for line in self.grid])
  
  def value(self, coordinates):
    (x, y) = coordinates
    return self.grid[y][x]
  
  def set_value(self, coordinates, value):
    (x, y) = coordinates
    self.grid[y][x] = value
    return self.value(coordinates)

  def all_coordinates(self):
    return [(x, y) for y in range(self.bounds[1]) for x in range(self.bounds[0])]

  def neighboring_coordinates(self, coordinates):
    # This time, include diagonals
    (x, y) = coordinates
    return [
      c
      for c in [(x, y - 1), (x + 1, y - 1), (x + 1, y), (x + 1, y + 1), (x, y + 1), (x - 1, y + 1), (x - 1, y), (x - 1, y - 1)] 
      if c[0] in range(0, self.bounds[0]) and c[1] in range(0, self.bounds[1])
    ]

class OctopusGrid(Grid):
  def __init__(self, grid):
    super().__init__(grid)
    self.step_count = 0
    self.flash_count = 0
  
  def step(self):
    for c in self.all_coordinates():
      self.set_value(c, self.value(c) + 1)

    for c in self.all_coordinates():
      v = self.value(c)

      if v > 9:
        self.flash(self, c)
    
    self.step_count += 1

  def flash(self, grid, c):
    self.flash_count += 1
    grid.set_value(c, 0)

    for nc in grid.neighboring_coordinates(c):
      nv = grid.value(nc)
      
      if nv == 0: # Already flashed this cycle
        continue
      else:
        new_nv = nv + 1
        if new_nv > 9:
          self.flash(grid, nc)
        else:
          grid.set_value(nc, new_nv)

og = OctopusGrid(octopi)
for n in range(100):
  og.step()

print("Pt 1:", og.flash_count)
