// http://adventofcode.com/2018/day/15
import Foundation

typealias Coordinate = (x: Int, y: Int)

enum Contents {
  case blank
  case wall
  case elf
  case goblin

  static func parse(_ c: Character) -> Contents? {
    switch c {
      case ".": return .blank
      case "#": return .wall
      case "G": return .goblin
      case "E": return .elf
      default: return nil
    }
  }
}

struct Cell : CustomStringConvertible {
  var contents: Contents

  static func parse(_ c: Character) -> Cell? {
    guard let contents = Contents.parse(c) else { return nil }
    return Cell(contents: contents)
  }

  var description:String {
    switch contents {
      case .blank: return "."
      case .wall: return "#"
      case .goblin: return "G"
      case .elf: return "E"
    }
  }

  var hasCreature:Bool {
    return [.goblin, .elf].contains(contents)
  }
}

class Maze : CustomStringConvertible, Sequence {
  var cells: [[Cell]]

  init(cells: [[Cell]]) {
    self.cells = cells
  }

  var description:String {
    return cells.map { $0.map { $0.description }.joined() }.joined(separator: "\n")
  }

  func makeIterator() -> AnyIterator<(Coordinate, Cell)> {
    let yMax = cells.count
    let xMax = cells[0].count

    var ix = 0
    var iy = 0

    return AnyIterator {
      if iy < yMax && ix < xMax {
        let coord = Coordinate(x: ix, y: iy)
        let cell = self.cells[iy][ix]

        ix += 1

        if ix >= xMax {
          ix = 0
          iy += 1
        }

        return (coord, cell)
      }

      return nil
    }
  }

  var allCreatures:[(Coordinate, Cell)] {
    return self.filter { (coord, cell) in return cell.hasCreature }
  }
}

var rows: [[Cell]] = []
while let line = readLine() {
  let row = Array(line).compactMap { Cell.parse($0) }
  rows.append(row)
}
var maze = Maze(cells: rows)

// print("\(maze.description)")
// for (coord, cell) in maze { print("\(coord) = \(cell)") }
for (coord, cell) in maze.allCreatures { print("\(coord) = \(cell)") }

print("Pt. 1: ?")
print("Pt. 2: {}", "???")
