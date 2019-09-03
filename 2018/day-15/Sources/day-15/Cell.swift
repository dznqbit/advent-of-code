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
    guard case .blank = contents else { return false }
    return true
  }
}

extension Cell : Equatable {
  static func ==(lhs: Cell, rhs: Cell) -> Bool {
    return lhs.id == rhs.id
  }
}

enum RoundResult {
  case complete
  case incomplete 
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
      if index.y >= height { return nil }
      if index.x >= cells[index.y].count { return nil }

      return cells[index.y][index.x]
    }

    set(newValue) {
      guard let value = newValue else { return }
      if index.y >= height { return }
      if index.x >= cells[index.y].count { return }
      cells[index.y][index.x] = value
    }
  }

  var height:Int { return cells.count }
  var width:Int {
    if cells.isEmpty {
      return 0
    } else {
      return cells[0].count
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

  func coordinate(for creature: Creature) -> Coordinate? {
    guard let creatureCell = self[creature] else { return nil }
    return coordinate(for: creatureCell)
  }

  func readIndex(_ coordinate: Coordinate) -> Int {
    return coordinate.y * width + coordinate.x
  }

  /// Return iterator over all Coordinates/Cells.
  func makeIterator() -> AnyIterator<(Coordinate, Cell)> {
    var ix = 0
    var iy = 0

    return AnyIterator {
      let coord = Coordinate(x: ix, y: iy)
      guard let cell = self[coord] else { return nil }

      ix += 1

      if ix >= self.width {
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
        let newNeighborPathCost = pathCosts[neighbor, default: 999999]
        if neighborCost < newNeighborPathCost ||
          (neighborCost == newNeighborPathCost && readIndex(current) < readIndex(breadcrumbs[neighbor]!)) {
          pathCosts[neighbor] = neighborCost
          let neighborPriority = neighborCost + heuristic(destination, neighbor)
          frontier.insert(neighbor, priority: neighborPriority)
          breadcrumbs[neighbor] = current
        }
      }
    }

    return nil
  }

  /// All creatures move/attack
  func executeRound() -> RoundResult {
    for creature in allCreatures {
      guard let creatureCell = self[creature],
      let creatureCoordinate = coordinate(for: creatureCell) else {
        // We can hit this when a creature dies earlier in the round.
        continue
      }

      if findEnemies(creature).isEmpty { return .incomplete }

      let accessibleEnemies:[(Creature, Path)] = findAccessibleEnemies(creature)
      let pathIsAdjacent: ((Creature, Path)) -> Bool = { $0.1.count <= 2 }
      let adjacentEnemies = accessibleEnemies.filter(pathIsAdjacent)
      func findWeakestEnemy(_ enemies: [(Creature, Path)]) -> Creature? {
        return enemies.map { return $0.0 }
          .sorted { $0.hitPoints < $1.hitPoints }
          .first
      }

      if let weakestEnemy = findWeakestEnemy(adjacentEnemies) {
        // Attack
        // print("Attack \(weakestEnemy.longDescription) of \(adjacentEnemies.map { $0.0.longDescription }.joined(separator: ","))")
        attack(weakestEnemy, attackPower: creature.attackPower)
      } else {
        // Move

        // Choose the highest-ranking square adjacent TO THE ENEMY
        let enemiesByHighestRankingPath = accessibleEnemies
          .sorted { readIndex($0.1[$0.1.count - 2]) < readIndex($1.1[$1.1.count - 2]) }

        guard let (_, closestEnemyPath) = enemiesByHighestRankingPath.first else { continue }
        let nextCoordinate = closestEnemyPath[1]
        move(creature, to: nextCoordinate)

        // Try Attack
        let newAdjacentEnemies = findAccessibleEnemies(creature).filter(pathIsAdjacent)
        if let weakestEnemy = findWeakestEnemy(newAdjacentEnemies) {
        // print("Attack \(weakestEnemy.longDescription) of \(newAdjacentEnemies.map { $0.0.longDescription }.joined(separator: ","))")
          attack(weakestEnemy, attackPower: creature.attackPower)
        }
      }
    }

    return .complete
  }

  /// Attack a creature. If creature's HP falls to 0, they and the Cell becomes empty
  func attack(_ creature: Creature, attackPower: UInt) {
    guard var creatureCell = self[creature],
    let coordinate = coordinate(for: creatureCell), 
    case var .creature(writeCreature) = creatureCell.contents else { return }

    let newHitPoints = writeCreature.hitPoints - Swift.min(writeCreature.hitPoints, 3)

    if newHitPoints == 0 {
      print("\(creature.longDescription) died!")
      creatureCell.contents = .blank
    } else {
      writeCreature.hitPoints = newHitPoints
      creatureCell.contents = .creature(writeCreature)
    }

    self[coordinate] = creatureCell
  }

  /// Move a given creature to the Cell at targetCoordinate.
  func move(_ creature: Creature, to targetCoordinate: Coordinate) {
    guard var creatureCell = self[creature],
    let creatureCoordinate = coordinate(for: creatureCell),
    var targetCell = self[targetCoordinate] else {
      print("move: SOMETHINGS WRONG")
      return
    }

    switch targetCell.contents {
    case .blank:
      creatureCell.contents = .blank
      self[creatureCoordinate] = creatureCell
      targetCell.contents = .creature(creature)
      self[targetCoordinate] = targetCell
    default:
      print("move: SOMETHINGS WRONG")
    }
  }

  /// Find all living enemies
  func findEnemies(_ creature: Creature) -> [Creature] {
    return allCreatures
      .filter {
        switch (creature.species, $0.species) {
          case (.elf, .goblin), (.goblin, .elf): return true
          default: return false
        }
      }
  }

  /// Return all available enemies for creature
  func findAccessibleEnemies(_ creature: Creature) -> [(Creature, Path)] {
    guard let creatureCoordinate = coordinate(for: creature) else { return [] }

    return findEnemies(creature)
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


