# http://adventofcode.com/2021/day/4
import re
from sys import __stdin__

input = __stdin__.read()
lines = input.splitlines()
numbers = [int(s) for s in lines[0].split(",")]

# Return 5x5 grids of [[Int]]
def parse_sheets(lines):
  sheet = []
  for line in lines:
    if len(line) > 0:
      sheet.append([int(s) for s in re.findall(r'\d+', line)])
    
    if len(sheet) == 5:
      yield sheet
      sheet = []

class GameSheet:
  def __init__(self, sheet):
    self.sheet = [list((n, False) for n in row) for row in sheet]
  
  def mark(self, n):
    for row in self.sheet:
      for i in range(0, len(row)):
        if row[i][0] == n:
          row[i] = (row[i][0], True)
  
  def sum_of_unmarked_numbers(self):
    unmarked_numbers = [n for row in self.sheet for (n, t) in row if not t]
    return sum(unmarked_numbers)

  def is_winning(self):
    for row in self.sheet:
      if all(t for (_, t) in row):
        return True
    
    for i in range(0, 5):
        column = [row[i] for row in self.sheet]
        if all(t for (_, t) in column):
          return True

  def __str__(self):
    return "\n".join(" ".join(("%s%d" % ("*" if m else "", n)).rjust(3) for (n, m) in row) for row in self.sheet)

sheets = list(parse_sheets(lines[2::]))
game_sheets = [GameSheet(s) for s in sheets]

winning_sheet = None
winning_number = None

for n in numbers:
  for game_sheet in game_sheets:
    game_sheet.mark(n)
    if (game_sheet.is_winning()):
      winning_sheet = game_sheet
      winning_number = n
  
  if winning_sheet:
    break

print(f"Pt 1: {winning_sheet.sum_of_unmarked_numbers() * winning_number}")

unwinning_game_sheets = list(filter(lambda gs: not gs.is_winning(), game_sheets))
last_winning_number = None
last_winning_game_sheet = None

for n in numbers[numbers.index(winning_number)::]:
  for game_sheet in unwinning_game_sheets:
    game_sheet.mark(n)
    
    if game_sheet.is_winning() and len(unwinning_game_sheets) == 1:
      last_winning_game_sheet = game_sheet
      last_winning_number = n

  now_winning_game_sheets = list(filter(lambda gs: gs.is_winning(), unwinning_game_sheets))
  for gs in now_winning_game_sheets:
    unwinning_game_sheets.remove(gs)

  if last_winning_game_sheet:
    break

print(f"Pt 2: {last_winning_game_sheet.sum_of_unmarked_numbers() * last_winning_number}")
