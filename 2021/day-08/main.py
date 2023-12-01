# http://adventofcode.com/2021/day/8
from sys import __stdin__

input = __stdin__.read()
# print(input)

digits_to_segment_counts = { 0: 6, 1: 2, 2: 5, 3: 5, 4: 4, 5: 5, 6: 6, 7: 3, 8: 7, 9: 6 }
inputs_and_outputs = [tuple(v.strip().split(" ") for v in l.split("|")) for l in input.splitlines()]

unique_outputs = [n[1] for n in inputs_and_outputs for s in n[1] if len(s) in [2, 4, 3, 7]]
print("Pt 1:", len(unique_outputs))
