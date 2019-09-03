// http://adventofcode.com/2018/day/15
import Foundation

var rows: [[Cell]] = []
while let line = readLine() {
  let row = Array(line).compactMap { Cell.parse($0) }
  rows.append(row)
}

var maze = Maze(cells: rows)
var roundIndex = 0

while case .complete = maze.executeRound() {
  roundIndex += 1
  print("Round \(roundIndex) Complete")
  print(maze)
}

for creature in maze.allCreatures {
  print(creature.longDescription)
}
let summedHitPoints = maze.allCreatures.map { $0.hitPoints }.reduce(0, +)

print("Pt. 1: \(roundIndex * Int(summedHitPoints))")
print("Pt. 2: {}", "???")
