# http://adventofcode.com/2022/day/01
from sys import __stdin__

lines = [line.strip() for line in __stdin__.readlines()]

def split_array(array, split_token):
  result = [[]]
  
  for n in array:
    if n == split_token:
      result.append([])
    else:
      result[-1].append(n)

  return filter(lambda n: len(n) > 0, result)

elf_food_items = [map(int, food_items) for food_items in split_array(lines, '')]
elf_calorie_counts = [sum(n) for n in elf_food_items]
maximum_calorie_count = max(elf_calorie_counts)

print("Pt 1:", maximum_calorie_count)

elf_calorie_counts.sort(reverse=True)
print("Pt 2:", sum(elf_calorie_counts[0:3]))
