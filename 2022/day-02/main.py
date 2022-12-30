# http://adventofcode.com/2022/day/2
from enum import Enum
from functools import reduce
from sys import __stdin__

# Pt 1: What would your total score be if everything goes exactly according to your strategy guide?
# The winner of the whole tournament is the player with the highest score.
# Your total score is the sum of your scores for each round.
# { X: Rock, Y: Paper, Z: Scissors }
# The score for a single round is the score for the shape you selected (1 for Rock, 2 for Paper, and 3 for Scissors) 
# plus the score for the outcome of the round (0 if you lost, 3 if the round was a draw, and 6 if you won).

Move = Enum('Move', ['Rock', 'Paper', 'Scissors'])
Result = Enum('Result', ['Win', 'Lose', 'Draw'])

scores = { Move.Rock: 1, Move.Paper: 2, Move.Scissors: 3 }
round_scores = { Result.Win: 6, Result.Lose: 0, Result.Draw: 3 }

lines = __stdin__.readlines()

mc = { 'A': Move.Rock, 'B': Move.Paper, 'C': Move.Scissors, 'X': Move.Rock, 'Y': Move.Paper, 'Z': Move.Scissors }
sg = [(mc[p[0]], mc[p[1]]) for p in [line.strip().split(' ') for line in lines]]

def winner(x, y):
  ix = list(Move).index(x)
  iy = list(Move).index(y)

  if x == y:
    return None
  elif ix == (iy + 1) % 3:
    return x
  else:
    return y

def result(opp, p):
  w = winner(opp, p)

  if w == opp:
    return Result.Lose
  if w == p:
    return Result.Win
  else:
    return Result.Draw

def score(round):
  (opp, p) = round
  r = result(opp, p)
  return scores[p] + round_scores[r]

print("Pt 1:", sum([score(round) for round in sg]))

mc2 = { 'A': Move.Rock, 'B': Move.Paper, 'C': Move.Scissors, 'X': Result.Lose, 'Y': Result.Draw, 'Z': Result.Win }
sg2 = [(mc2[p[0]], mc2[p[1]]) for p in [line.strip().split(' ') for line in lines]]

def choose_move(round):
  (x, r) = round
  ix = list(Move).index(x)

  if r == Result.Draw:
    return x
  elif r == Result.Win:
    return list(Move)[(ix + 1) % 3]
  elif r == Result.Lose:
    return list(Move)[ix - 1]

pt2sg = [(round[0], choose_move(round)) for round in sg2]
print("Pt 2:", sum(score(round) for round in pt2sg))
