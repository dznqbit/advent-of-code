// http://adventofcode.com/2018/day/13

extension Sequence {
  func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
    return self.map {
      $0[keyPath: keyPath]
    }
  }

  func flatMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
    return self.compactMap {
      $0[keyPath: keyPath]
    }
  }
}

typealias Position = (x: Int, y: Int)
func +(a: Position, b: Position) -> Position {
  return Position(x: a.x + b.x, y: a.y + b.y)
}

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0...length-1).map{ _ in letters.randomElement()! })
}

enum RelativeDirection {
  case left
  case right
  case straight
}

enum Direction {
  case up
  case right
  case down
  case left

  func toVector() -> Position {
    switch self {
      case .up: return Position(x: 0, y: -1)
      case .right: return Position(x: 1, y: 0)
      case .down: return Position(x: 0, y: 1)
      case .left: return Position(x: -1, y: 0)
    }
  }

  static func +(d: Direction, rd: RelativeDirection) -> Direction {
    switch rd {
      case .straight: return d
    case .left:
      switch d {
        case .up: return .left
        case .right: return .up
        case .down: return .right
        case .left: return .down
      }
      case .right:
        switch d {
          case .up: return .right
          case .right: return .down
          case .down: return .left
          case .left: return .up
        }
    }
  }
}

enum Track {
  case horizontalTrack
  case verticalTrack
  // Curves are a little tricky as only 2 glyphs can mean 4 different 
  // entry/exit points. Naming is from perspective of bottom, so depending
  // on direction you might take a left on a "right" turn.
  // right=/ left=\
  case rightCurve 
  case leftCurve
  case intersection
}

class Cart : CustomStringConvertible, Hashable {
  let id: String
  var direction: Direction
  var intersectionDirection: RelativeDirection

  init(_ direction: Direction) {
    self.id = randomString(length: 10)
    self.direction = direction
    self.intersectionDirection = .left
  }

  static func == (a: Cart, b: Cart) -> Bool {
    return a.id == b.id
  }

  var hashValue: Int {
    return id.hashValue
  }

  func updateDirection(_ track: Track) {
    switch (track, direction) {
      case (.horizontalTrack, _): break
      case (.verticalTrack, _): break

      // Remember, these curves are tricky and cannot be reduced to simple
      // addition operations.
      case (.rightCurve, .right): self.direction = .up
      case (.rightCurve, .down): self.direction = .left
      case (.rightCurve, .left): self.direction = .down
      case (.rightCurve, .up): self.direction = .right

      case (.leftCurve, .right): self.direction = .down
      case (.leftCurve, .down): self.direction = .right
      case (.leftCurve, .left): self.direction = .up
      case (.leftCurve, .up): self.direction = .left

    case(.intersection, _):
      self.direction = direction + intersectionDirection

      switch intersectionDirection {
        case .left: self.intersectionDirection = .straight 
        case .straight: self.intersectionDirection = .right 
        case .right: self.intersectionDirection = .left
      }
    } // switch
  }

  var description: String {
    switch direction {
      case .up: return "^"
      case .right: return ">"
      case .down: return "v"
      case .left: return "<"
    }
  }
}

class Cell : CustomStringConvertible {
  let track: Track?
  var cart: Cart?
  var crashedCarts: [Cart]

  init(track: Track?, cart: Cart?) {
    self.track = track
    self.cart = cart
    self.crashedCarts = []
  }

  var description: String {
    if let t = track {
      // if crashedCarts.count > 0 { return "X" }
      if let c = cart {
        return c.description
      } else {
        switch t {
          case .horizontalTrack: return "-"
          case .verticalTrack: return "|"
          case .rightCurve: return "/"
          case .leftCurve: return "\\"
          case .intersection: return "+"
        }
      }
    } else {
      return " "
    }
  }
}

struct CellIterator : IteratorProtocol {
  let rows: [[Cell]]
  var rowIndex: Int = 0
  var cellIndex: Int = 0

  init(_ rows: [[Cell]]) {
    self.rows = rows
  }

  mutating func next() -> (Position, Cell)? {
    guard rowIndex < rows.count else { return nil }
    let row = rows[rowIndex]

    if cellIndex < row.count {
      let cell = row[cellIndex]
      let position = Position(x: cellIndex, y: rowIndex)
      cellIndex += 1
      return (position, cell)
    } else {
      rowIndex += 1
      cellIndex = 0
      return next()
    }
  }
}

class Board : CustomStringConvertible {
  var cartPositions: [Cart:Position]
  var cells: [[Cell]]

  init(_ cells: [[Cell]]) {
    self.cells = cells
    self.cartPositions = [:]

    let cartCells = self.filter { $0.1.cart != nil }
    for (position, cell) in cartCells {
      if let cart = cell.cart {
        cartPositions[cart] = position
      }
    }
  }

  subscript(position: Position) -> Cell? {
    get {
      if !cells.indices.contains(position.y) { return nil }
      let row = cells[position.y]

      if !row.indices.contains(position.x) { return nil }
      return row[position.x]
    }

    set(av) {
      guard let v = av else { return }

      if !cells.indices.contains(position.y) { return }
      var row = cells[position.y]

      if !row.indices.contains(position.x) { return }
      row[position.x] = v
      cells[position.y] = row
    }
  }

  var height: Int { return cells.count }
  var width: Int { return cells.map(\Array.count).max()! }

  var description: String {
    return cells.map { $0.map(\Cell.description)
    .joined(separator: "") }.joined(separator: "\n")
  }

  func tick() {
    for (cart, position) in cartPositions {
      guard let cell = self[position] else {continue }
      guard cell.cart == cart else { continue }

      let newPosition = cart.direction.toVector() + position
      guard let newCell = self[newPosition] else { continue }
      cell.cart = nil

      if let existingCart = newCell.cart {
        newCell.crashedCarts.append(existingCart)
        newCell.crashedCarts.append(cart)
        newCell.cart = nil
        cartPositions.removeValue(forKey: existingCart)
        cartPositions.removeValue(forKey: cart)
        continue
      }

      newCell.cart = cart
      cartPositions[cart] = newPosition
      guard let track = newCell.track else { return }
      cart.updateDirection(track)
    }
  }
}

extension Board : Sequence {
  func makeIterator() -> CellIterator { return CellIterator(cells) }
}

enum MapCharacter {
  case nothing
  case track(Track)
  case trackAndCart(Track, Cart)
  case crash

  static func parse(_ c: Character) -> MapCharacter {
    switch c {
      case "-": return .track(.horizontalTrack)
      case "|": return .track(.verticalTrack)
      case "/": return .track(.rightCurve)
      case "\\": return .track(.leftCurve)
      case "+": return .track(.intersection)
      case "v": return .trackAndCart(.verticalTrack, Cart(.down))
      case "<": return .trackAndCart(.horizontalTrack, Cart(.left))
      case "^": return .trackAndCart(.verticalTrack, Cart(.up))
      case ">": return .trackAndCart(.horizontalTrack, Cart(.right))
      case "X": return .crash
    default:
      return .nothing
    }
  }
}

var cells: [[Cell]] = []
while let line = readLine() {
  let row = Array(line).map({ chr -> Cell in 
    switch MapCharacter.parse(chr) {
      case let .track(t): return Cell(track: t, cart: nil)
      case let .trackAndCart(t, c): return Cell(track: t, cart: c)
      case .nothing: return Cell(track: nil, cart: nil)
      case .crash: return Cell(track: nil, cart: nil)
    }
                            })

  cells.append(row)
}

var board = Board(cells)

for _ in 0...100000 {
  let crashedCells = board.filter { $0.1.crashedCarts.count > 0 }
  if let (p, _) = crashedCells.first { 
    print("Pt. 2: \(p.x),\(p.y)")
    break 
  }

  board.tick()
}

// Wrong guesses: (44, 80), (43, 80)
for _ in 0...100000 {
  let cartCells = board.filter { $0.1.cart != nil }
  if cartCells.count <= 1 {
    if let (p, _) = cartCells.first {
      print("Pt. 2: \(p.x),\(p.y)")
    } else {
      print("Pt. 2: ???")
    }
    break 
  }

  board.tick()
}
