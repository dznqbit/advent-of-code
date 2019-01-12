import Foundation

struct Unit {
  var chr: Unicode.Scalar
  var polarity:Bool { return chr.value > 90 }
  var value:UInt    { return UInt(chr.value > 90 ? (chr.value - 97) : (chr.value - 65)) }

  init(_ chr:Unicode.Scalar) {
    self.chr = chr
  }
}

struct UnitPair {
  var u1: Unit
  var u2: Unit
  init(_ u1:Unit, _ u2:Unit) {
    self.u1 = u1
    self.u2 = u2
  }

  func isVolatile() -> Bool { return self.u1.value == self.u2.value && self.u1.polarity != self.u2.polarity }
}

struct Polymer {
  var units:[Unit]

  init(_ units:[Unit]) {
    self.units = units
  }

  init(_ s:String) {
    self.units =  s.unicodeScalars.map { Unit($0) }
  }

  func reduce() -> Optional<Polymer> {
    if let vIndex = self.volatileIndex() {
      var newUnits = self.units
      newUnits.removeSubrange(vIndex...(vIndex + 1))
      return Optional(Polymer(newUnits))
    }

    return nil
  }

  func without(_ value: UInt) -> Optional<Polymer> {
    return Optional(Polymer(self.units.filter { $0.value != value }))
  }

  func volatileIndex() -> Optional<Int> {
    for x in 0..<(self.units.count - 1) {
      let u1 = self.units[x]
      let u2 = self.units[x + 1]
      let unitPair = UnitPair(u1, u2) 

      if (unitPair.isVolatile()) {
        return Optional(x)
      }
    }

    return nil
  }
}

extension String {
  init(_ p: Polymer) { 
    self = String(p.units.map { Character($0.chr) })
  }
}

func reduce(_ p: Polymer) -> Optional<Polymer> {
  var polymers: [Polymer] = [p]
  while let tail = polymers.last?.reduce() { polymers.append(tail) }
  return polymers.last
}

if let line = readLine() {
  let polymer = Polymer(line)

  if let reducedPolymer = reduce(polymer) {
    let rps = String(reducedPolymer)
    print("Pt 1:", rps.count, "(\(rps))")
  }

  var reductions: [UInt:String] = [:]

  for i in 0..<26 {
    let value = UInt(i)
    let alteredPolymer = polymer.without(value)
    let reducedAlteredPolymer = reduce(alteredPolymer!)
    reductions[value] = String(reducedAlteredPolymer!)
  }

  let leastReactivePolymer = reductions.min { a, b in a.value.count < b.value.count }
  print("Pt 2:", leastReactivePolymer!.value.count, "(\(leastReactivePolymer!.value))")
} else {
  print("No input!")
}
