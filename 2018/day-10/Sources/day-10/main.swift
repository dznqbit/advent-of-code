// http://adventofcode.com/2018/day/10

import Foundation

struct Vec : Hashable {
  var x = 0, y = 0

  static func + (left: Vec, right: Vec) -> Vec {
    return Vec(x: left.x + right.x, y: left.y + right.y)
  }
}

struct Point : CustomStringConvertible {
  var position: Vec
  let velocity: Vec

  static func parse(_ s: String) -> Optional<Point> {
    let pattern = "position=<\\s*(-?\\d+),\\s*(-?\\d+)> velocity=<\\s*(-?\\d+),\\s*(-?\\d+)>"
    guard let re = try? NSRegularExpression.init(pattern: pattern) else { return nil }

    let range = NSRange(s.startIndex..., in: s)
    guard let match = re.firstMatch(in: s, range: range) else { return nil }
    let numbers = (1...4).makeIterator()
      .map { Range(match.range(at: $0), in: s)! }
      .map { Int(String(s[$0]))! }

    return Point(position: Vec(x: numbers[0], y: numbers[1]), velocity: Vec(x: numbers[2], y: numbers[3]))
  }

  var description: String {
    return "P<\(position.x), \(position.y)> V<\(velocity.x), \(velocity.y)>"
  }
}

class Field {
  var points: [Point]
  var elapsedSeconds: Int

  init(points: [Point]) {
    self.points = points
    self.elapsedSeconds = 0
  }

  func tick() {
    for i in 0..<points.count {
      let point = points[i]
      points[i].position = point.position + point.velocity
    }

    elapsedSeconds += 1
  }

  func isClose() -> Bool {
    let allPositions = points.map { $0.position }
    let allAdjacentPositions = allPositions.flatMap {
      return [$0 + Vec(x: 1, y: 1), $0 + Vec(x: 1, y: -1), $0 + Vec(x: -1, y: -1), $0 + Vec(x: -1, y: 1)]
    }
    let adjacentPointPositions = Set(allPositions).intersection(allAdjacentPositions)

    return adjacentPointPositions.count > 5
  }

  func draw() -> String {
    var positions: [Vec: Character] = [:]
    for point in points { positions[point.position] = "#" }
    let pointPositions = positions.keys

    let xMax = pointPositions.map { $0.x }.max()!
    let xMin = pointPositions.map { $0.x }.min()!
    let yMax = pointPositions.map { $0.y }.max()!
    let yMin = pointPositions.map { $0.y }.min()!

    let xMid = xMax - xMin / 2
    let xRange = 150 ... 250

    let yMid = yMax - yMin / 2
    let yRange = 185 ... 215

    var rows: [String] = ["T\(elapsedSeconds) y\(yRange) x\(xRange)"]
    for y in yRange {
      var row: [Character] = []
      for x in xRange { row.append(positions[Vec(x: x, y: y), default: "."]) }
      rows.append(String(row))
    }

    return rows.joined(separator: "\n")
  }
}

var points: [Point] = []
while let line = readLine(), let point = Point.parse(line) { points.append(point) }
var field = Field(points: points)
var counter = 1

// I just let this run indefinitely and eyeballed it.
//
// There are some magic numbers up in draw() that framed my problem's solution - you'll probably have to play
// with taht frame to find your solution.
/*
while true {
  let fs = field.draw()

  if field.isClose() {
    print(fs)
    usleep(100000)
  }

  field.tick()
}
*/

print("Pt. 1: {}", "???")
print("Pt. 2: {}", "???")
