// http://adventofcode.com/2018/day/11
import Foundation

struct Coordinate : Hashable, CustomStringConvertible {
  let x: Int, y: Int

  var description: String { return "(\(x),\(y))" }
}

struct CoordinateRange: Hashable, CustomStringConvertible, Sequence {
  let x: ClosedRange<Int>, y: ClosedRange<Int>

  static func build(_ a: Coordinate, b: Coordinate) -> CoordinateRange? {
    if let xMin = [a.x, b.x].min(), let xMax = [a.x, b.x].max(),
       let yMin = [a.y, b.y].min(), let yMax = [a.y, b.y].max()
    { return CoordinateRange(x: xMin...xMax, y: yMin...yMax) }
    else { return nil }
  }

  var description: String { return "(\(x), \(y))" }
  var count: Int { return x.count * y.count }

  func makeIterator() -> AnyIterator<Coordinate> {
    let xFirst = x.first!
    let yFirst = y.first!
    let yLast = y.last!

    var ix = xFirst
    var iy = yFirst

    return AnyIterator {
      if self.x.contains(ix) && self.y.contains(iy) {
        let c = Coordinate(x: ix, y: iy)

        if iy < yLast {
          iy += 1
        } else {
          iy = yFirst
          ix += 1
        }

        return c
      }

      return nil
    }
  }
}

extension Array where Element == Coordinate {
  init(_ cr: CoordinateRange) {
    self = []
    for c in cr { append(c) }
  }
}

class PowerLevelCalculator {
  let serialNumber: Int

  private var _cpls: [Coordinate:Int] = [:]
  private var _rpls: [CoordinateRange:Int] = [:]

  init(serialNumber: Int) {
    self.serialNumber = serialNumber
  }

  func powerLevel(_ coordinateRange: CoordinateRange) -> Int? {
    var pl = _rpls[coordinateRange]

    if pl == nil {
      if coordinateRange.count == 1 {
        for c in coordinateRange { pl = powerLevel(c) }
      } else if coordinateRange.count > 1 && coordinateRange.count <= 4 {
        pl = coordinateRange.map { powerLevel($0) }.reduce(0, +)
      } else if coordinateRange.count > 4 {
        let xr = coordinateRange.x
        let yr = coordinateRange.y

        let xf = xr.first!
        let xl = xr.last!
        let xm = xf + ((xl - xf) / 2)

        let xr1 = xf...xm
        let xr2 = xm+1...xl

        let yf = yr.first!
        let yl = yr.last!
        let ym = yf + ((yl - yf) / 2)

        let yr1 = yf...ym
        let yr2 = ym+1...yl

        let qs = [
          CoordinateRange(x: xr1, y: yr1),
          CoordinateRange(x: xr1, y: yr2),
          CoordinateRange(x: xr2, y: yr1),
          CoordinateRange(x: xr2, y: yr2)
        ]

        pl = qs.compactMap { powerLevel($0) }.reduce(0, +)
      }
    }

    if let rpl = pl {
      _rpls[coordinateRange] = rpl
      return rpl
    } else {
      return nil
    }
  }

  func powerLevel(_ coordinate: Coordinate) -> Int {
    
    if let powerLevel = _cpls[coordinate] { return powerLevel }
    else {
      let powerLevel = type(of: self).powerLevel(coordinate: coordinate, gridSerialNumber: serialNumber)
      _cpls[coordinate] = powerLevel
      return powerLevel
    }
  }

  static func powerLevel(coordinate: Coordinate, gridSerialNumber: Int) -> Int {
    let rackId = (coordinate.x + 10)
    return (((((rackId * coordinate.y) + gridSerialNumber) * rackId) % 1000) / 100) - 5
  }
}

func findLargestSquareWithSize(
  bounds: (x: ClosedRange<Int>, y: ClosedRange<Int>),
  squareSize: Int,
  calculator: inout PowerLevelCalculator
  ) -> (key: Coordinate, value: Int)? {
  var squarePowerLevels: [Coordinate: Int] = [:]
  let border = squareSize - 1

  for y in (bounds.y.lowerBound...(bounds.y.upperBound - border)) {
    for x in (bounds.x.lowerBound...(bounds.x.upperBound - border)) {
      let c = Coordinate(x: x, y: y)
      let coordinates = CoordinateRange(x: x...(x+squareSize-1), y: y...(y+squareSize-1))
      squarePowerLevels[c] = calculator.powerLevel(coordinates)
    }
  }

  return squarePowerLevels.max(by: { a,b in a.value < b.value })
}

func findLargestSquare(
  bounds: (x: ClosedRange<Int>, y: ClosedRange<Int>),
  calculator: inout PowerLevelCalculator
  ) -> (Coordinate, Int, Int)? {
  var maximumPowerPerSquareSize: [Int: (Coordinate, Int)] = [:]

  if let largestSquareSize = [bounds.x.upperBound, bounds.y.upperBound].max() {
    for squareSize in 1...largestSquareSize {
      if let c = findLargestSquareWithSize(bounds: bounds, squareSize: squareSize, calculator: &calculator) {
        maximumPowerPerSquareSize[squareSize] = c
      }
    }

    if let max = maximumPowerPerSquareSize.max(by: { a, b in a.value.1 < b.value.1  }) {
      return (max.value.0, max.value.1, max.key)
    }
  }

  return nil
}

if let gridSerialNumber = Int(readLine()!) {
  var calculator = PowerLevelCalculator(serialNumber: gridSerialNumber)

  if let c = findLargestSquareWithSize(
    bounds: (x: 1...300, y: 1...300),
    squareSize: 3,
    calculator: &calculator
  ) {
    print("Pt. 1: \(c.key.x),\(c.key.y)")
  }

  if let c = findLargestSquare(
    bounds: (x: 1...300, y: 1...300),
    calculator: &calculator
  ) {
    print("Pt. 2: \(c.0.x),\(c.0.y),\(c.2)")
  }
}
