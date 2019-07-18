struct Coordinate : Hashable {
  let x: Int
  let y: Int

  /// Return neighboring coordinates in READ ORDER!
  var neighbors: [Coordinate] {
    return [(0, -1), (-1, 0), (1, 0), (0, 1)].map { Coordinate(x: x + $0.0, y: y + $0.1) }
  }
}

typealias Path = [Coordinate]

enum Species {
  case elf
  case goblin
}

struct Creature {
  static var nextId: UInt = 0

  let id: UInt
  var hitPoints: UInt
  let attackPower: UInt
  let species: Species

  init(species: Species) {
    self.id = Creature.nextId
    Creature.nextId += 1
    self.hitPoints = 200
    self.attackPower = 3
    self.species = species
  }

  static func elf() -> Creature { return .init(species: .elf) }
  static func goblin() -> Creature { return .init(species: .goblin) }
}

extension Creature : Equatable {
  static func ==(lhs: Creature, rhs: Creature) -> Bool {
    return lhs.id == rhs.id
  }
}

enum Contents {
  case blank
  case creature(Creature)
  case wall
}

struct Cell {
  static var nextId: UInt = 0

  let id: UInt
  var contents: Contents

  init(contents: Contents) {
    self.id = Cell.nextId
    Cell.nextId += 1
    self.contents = contents
  }

  var isTraversible:Bool {
    switch contents {
      case .blank: return true
      default: return false
    }
  }
}

extension Cell : Equatable {
  static func ==(lhs: Cell, rhs: Cell) -> Bool {
    return lhs.id == rhs.id
  }
}

class Maze : Sequence {
  var cells: [[Cell]]

  init(cells: [[Cell]]) {
    self.cells = cells
  }

  /// Return all creatures, ordered by reading order.
  var allCreatures:[Creature] {
    return compactMap { (coordinate, cell) -> Creature? in
      switch cell.contents {
        case let .creature(c): return c
        default: return nil
      }
    }
  }

  /// Return the Cell at Coordinate.
  subscript(index: Coordinate) -> Cell? {
    get {
      if index.y >= cells.count { return nil }
      if index.x >= cells[index.y].count { return nil }

      return cells[index.y][index.x]
    }

    set(newValue) {
      guard let value = newValue else { return }
      if index.y >= cells.count { return }
      if index.x >= cells[index.y].count { return }
      cells[index.y][index.x] = value
    }
  }

  /// Return the Cell containing the creature.
  subscript(creature: Creature) -> Cell? {
    for (_, cell) in self {
      switch cell.contents {
        case let .creature(c): if c == creature { return cell }
        default: continue
      }
    }

    return nil
  }

  /// Return the Coordinate for the Cell.
  func coordinate(for myCell: Cell) -> Coordinate? {
    for (coordinate, cell) in self {
      if cell == myCell { return coordinate }
    }

    return nil
  }

  /// Return iterator over all Coordinates/Cells.
  func makeIterator() -> AnyIterator<(Coordinate, Cell)> {
    let xMax = cells[0].count

    var ix = 0
    var iy = 0

    return AnyIterator {
      let coord = Coordinate(x: ix, y: iy)
      guard let cell = self[coord] else { return nil }

      ix += 1

      if ix >= xMax {
        ix = 0
        iy += 1
      }

      return (coord, cell)
    }
  }

  /// Compute shortest path between two points, if possible.
  /// Path will include the origin and destination.
  /// Uses A* to go FAST!
  func findPath(from origin: Coordinate, to destination: Coordinate) -> Path? {
    let heuristic = { (a: Coordinate, b: Coordinate) -> UInt in
      return UInt(abs(a.x - b.x) + abs(a.y - b.y))
    }

    var breadcrumbs: [Coordinate:Coordinate] = [:]
    var pathCosts: [Coordinate:UInt] = [:]

    var frontier = PriorityQueue<Coordinate>()
    frontier.insert(origin, priority: 0)

    while let current = frontier.shift() {
      if current == destination {
        var path = [destination]

        while let c = path.first,
        let p = breadcrumbs[c] {
          path.insert(p, at: 0)
        }

        return path
      }

      let neighbors = current.neighbors

      let traversibleNeighbors = neighbors
      .filter { coord in
        guard let cell = self[coord] else { return false }
        return (cell.isTraversible && !breadcrumbs.values.contains(coord)) ||
        coord == destination
      }

      for neighbor in traversibleNeighbors {
        let neighborCost = pathCosts[current, default: 0] + 1
        if !pathCosts.keys.contains(neighbor) || neighborCost < pathCosts[neighbor, default: 0] {
          pathCosts[neighbor] = neighborCost
          let neighborPriority = neighborCost + heuristic(destination, neighbor)
          frontier.insert(neighbor, priority: neighborPriority)
          breadcrumbs[neighbor] = current
        }
      }
    }

    return nil
  }

  /// Move a given creature to the Cell at targetCoordinate.
  func move(_ creature: Creature, to targetCoordinate: Coordinate) {
    guard var creatureCell = self[creature],
          let creatureCoordinate = coordinate(for: creatureCell),
          var targetCell = self[targetCoordinate] else {
      print("SOMETHINGS WRONG")
      return
    }

    switch targetCell.contents {
    case .blank:
      creatureCell.contents = .blank
      self[creatureCoordinate] = creatureCell

      targetCell.contents = .creature(creature)
      self[targetCoordinate] = targetCell
    default:
      print("SOMETHINGS WRONG")
    }
  }

  /// All creatures move/attack
  func executeRound() {
    for creature in allCreatures {
      // print("\(creature.longDescription) GO!")

      guard let creatureCell = self[creature],
      let creatureCoordinate = coordinate(for: creatureCell) else {
        print("SOMETHINGS WRONG")
        continue
      }

      let enemies:[(Creature, Path)] = allCreatures
      .filter {
        switch (creature.species, $0.species) {
          case (.elf, .goblin), (.goblin, .elf): return true
          default: return false
        }
      }
      .compactMap {
        if let enemyCell = self[$0],
        let enemyCoordinate = coordinate(for: enemyCell),
        let path = findPath(from: creatureCoordinate, to: enemyCoordinate) {
          return ($0, path)
        } else {
          return nil
        }
      }
      .sorted {
        return $0.1.count < $1.1.count
      }

      if let (_, closestEnemyPath) = enemies.first {
        switch closestEnemyPath.count {
        case 0, 1:
          print("SOMETHINGS WRONG")
        case 2:
          // print("ATTACK")
          continue
        default:
          let nextCoordinate = closestEnemyPath[1]
          move(creature, to: nextCoordinate)
        }
      } else {
        print("No accessible enemies!")
      }
    }
  }
}

/// MARK: String to/from

extension Coordinate : CustomStringConvertible {
  var description:String { return "(\(x), \(y))" }
}

extension Creature : CustomStringConvertible {
  var description:String {
    switch species {
      case .elf: return "E"
      case .goblin: return "G"
    }
  }

  var longDescription:String { 
    return "\(self)(\(self.id)) HP: \(self.hitPoints) AP \(self.attackPower)"
  }
}

extension Contents {
  static func parse(_ c: Character) -> Contents? {
    switch c {
      case ".": return .blank
      case "#": return .wall
      case "G": return .creature(Creature.goblin())
      case "E": return .creature(Creature.elf())
      default: return nil
    }
  }

  var longDescription:String {
    switch self {
      case .blank: return "."
      case .wall: return "#"
      case .creature(let c): return c.longDescription
    }
  }

  var description:String {
    switch self {
      case .blank: return "."
      case .wall: return "#"
      case .creature(let c): return c.description
    }
  }
}

extension Cell : CustomStringConvertible {
  static func parse(_ c: Character) -> Cell? {
    guard let contents = Contents.parse(c) else { return nil }
    return Cell(contents: contents)
  }

  var longDescription:String { return contents.longDescription }
  var description:String { return contents.description }
}


extension Maze : CustomStringConvertible {
  var description:String {
    return cells.map { $0.map { $0.description }.joined() }.joined(separator: "\n")
  }
}


