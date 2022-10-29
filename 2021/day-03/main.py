# http://adventofcode.com/2021/day/3
from sys import __stdin__
from collections import Counter
from tokenize import String

input = __stdin__.read()

# Transform to [[Int]]
report = [[int(c) for c in x] for x in input.splitlines()]

def rotate_report(report):
  return [
    [line[i] for line in report]
    for i in range(len(report[0]))
  ]

def calc_gamma_rate(report):
  rotated_report = rotate_report(report)

  m = [Counter(j).most_common(1)[0][0] for j in rotated_report]
  s = "".join([str(x) for x in m])
  return int(s, 2)

def calc_epsilon_rate(report):
  rotated_report = rotate_report(report)

  m = [Counter(j).most_common(1)[0][0] for j in rotated_report]
  s = "".join([str(1 if x == 0 else 0) for x in m])
  return int(s, 2)

gamma_rate = calc_gamma_rate(report)
epsilon_rate = calc_epsilon_rate(report)

print(f"Pt 1: {gamma_rate * epsilon_rate}")

def most_common(report, t, i = 0):
  zero_bits = [x for x in report if x[i] == 0]
  one_bits = [x for x in report if x[i] == 1]
  c = t(one_bits, zero_bits)
  matches = list(filter(lambda x: x[i] == c, report))
  if len(matches) == 1:
    return int("".join([str(n) for n in matches[0]]), 2)
  else:
    return most_common(matches, t, i + 1)

def calc_oxygen_generator_rating(report):
  return most_common(report, lambda one_bits, zero_bits: 1 if len(one_bits) >= len(zero_bits) else 0)

def calc_co2_generator_rating(report):
  return most_common(report, lambda one_bits, zero_bits: 1 if len(one_bits) < len(zero_bits) else 0)

oxygen_gen_rating = calc_oxygen_generator_rating(report)
co2_gen_rating = calc_co2_generator_rating(report)

print(f"Pt 2: {oxygen_gen_rating * co2_gen_rating}")
