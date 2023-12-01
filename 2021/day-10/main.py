# http://adventofcode.com/2021/day/10
from sys import __stdin__

input = __stdin__.read()
lines = input.splitlines()

point_bounties = { ")": 3, "]": 57, "}": 1197, ">": 25137 }
tag_pairs = [("(", ")"), ("[", "]"), ("{", "}"), ("<", ">")]

def find_first_invalid_closer(line):
  stack = []

  for c in line:
    if c in "([{<":
      stack.append(c)
    else:
      expected_opener = [tp[0] for tp in tag_pairs if tp[1] == c][0]

      if stack[-1] == expected_opener:
        stack.pop()
      else:
        return c
        #expected_closer = [tp[1] for tp in tag_pairs if tp[0] == stack[-1]][0]
        #print(f"{line} - Expected {expected_closer}, but found {c} instead.")


line_errors = [find_first_invalid_closer(line) for line in lines]
bounties = [point_bounties[c] for c in line_errors if c]
print("Pt 1:", sum(bounties))
