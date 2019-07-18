// http://adventofcode.com/2018/day/15
import Foundation

var rows: [[Cell]] = []
while let line = readLine() {
  let row = Array(line).compactMap { Cell.parse($0) }
  rows.append(row)
}
var maze = Maze(cells: rows)

for i in 0...3 {
  print("\nRound \(i)")
  print(maze.description)
  maze.executeRound()
}

print("Pt. 1: ?")
print("Pt. 2: {}", "???")
