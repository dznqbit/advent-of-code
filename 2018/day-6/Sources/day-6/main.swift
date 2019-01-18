// https://adventofcode.com/2018/day/6

import Foundation

enum AdventError: Error {
  case emptyList
}

struct Coordinate: Hashable {
  let x: Int
  let y: Int
}

typealias Bounds = (x: ClosedRange<Int>, y: ClosedRange<Int>)
typealias Distance = Int

func parse(_ s: String) -> Optional<Coordinate> {
    let a = s.split(separator: ",")
        .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        .map { Int($0) }

    guard let x = a[0], let y = a[1] else { return nil }
    return Optional(Coordinate(x: x, y: y))
}

// Compute Manhattan Distance between a + b
func distance(_ a: Coordinate, _ b: Coordinate) -> Distance { return abs(a.x - b.x) + abs(a.y - b.y) }

// Custom operator for job security
infix operator |---|: MultiplicationPrecedence
func |---|(a: Coordinate, b: Coordinate) -> Distance { return distance(a, b) }

// Find the outer limits of a list of Coordinate
func findBounds(_ inputCoordinate: [Coordinate]) -> Optional<Bounds> {
  guard let xMax = (inputCoordinate.map { $0.x }.max()) else { return nil }
  guard let xMin = (inputCoordinate.map { $0.x }.min()) else { return nil }
  guard let yMax = (inputCoordinate.map { $0.y }.max()) else { return nil }
  guard let yMin = (inputCoordinate.map { $0.y }.min()) else { return nil }

  return Optional((x: xMin...xMax, y: yMin...yMax))
}

// Build a list of coordinates inside the bounds (inclusive)
func generateCoordinates(_ bounds: Bounds) -> [Coordinate] {
  var coordinates: [Coordinate] = []
  for x in bounds.x { for y in bounds.y { coordinates.append(Coordinate(x: x, y: y)) } }
  return coordinates
}

// Find the closest Coordinate for c. Ties will be included.
func closestNeighbors(_ c: Coordinate, _ list: [Coordinate]) -> [Coordinate] {
  var neighborDistances: [Distance:[Coordinate]] = [:]

  for lc in list {
    let d = c |---| lc
    neighborDistances[d, default: []].append(lc)
  }

  if let neighborTuple = neighborDistances.min(by: { a, b in a.key < b.key }) {
    return neighborTuple.value
  } else {
    return []
  }
}

// Input Coordinates -> closest neighbors
func collectNeighbors(_ list: [Coordinate], _ coordinates: [Coordinate]) throws -> [Coordinate:[Coordinate]] {
  var neighbors: [Coordinate:[Coordinate]] = [:]

  for c in coordinates {
    let cns = closestNeighbors(c, list)
    switch cns.count {
      case 0:
        throw AdventError.emptyList

      case 1:
        guard let nc = cns.first else { throw AdventError.emptyList }
        neighbors[nc, default: []].append(c)

      default:
        break
    }
  }

  return neighbors
}

var inputCoordinates: [Coordinate] = []
while let line = readLine(), let c = parse(line) { inputCoordinates.append(c) }

if let bounds = findBounds(inputCoordinates) {
  let allCoordinates = generateCoordinates(bounds)

  // Pt 1
  let infiniteCoordinates = inputCoordinates.filter { c in
    [bounds.x.max(), bounds.x.min()].contains(c.x) || [bounds.y.max(), bounds.y.min()].contains(c.y)
  }

  var neighbors: [Coordinate:[Coordinate]] = try collectNeighbors(inputCoordinates, allCoordinates)
  for k in infiniteCoordinates { neighbors.removeValue(forKey: k) }

  if let maxBoundCoordinate = neighbors.max(by: { a, b in a.value.count < b.value.count }) {
    print("Pt 1: \(maxBoundCoordinate.value.count)")
  }

  // Pt 2
  let maxTotalDistance = 10000
  let distances = allCoordinates
    .flatMap { c in inputCoordinates.map { c |---| $0 }.reduce(0, +) }
    .filter  { d in d < maxTotalDistance }
    .count

  print("Pt 2: \(distances)")
}
