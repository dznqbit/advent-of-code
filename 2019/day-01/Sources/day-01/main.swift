// http://adventofcode.com/2019/day/01
import Bow
import BowOptics

var masses: [Int] = []
while let massString = readLine() {
  if let mass = Int(massString) {
    masses.append(mass)
  }
}

func calculateFuel(mass: Int) -> Int {
  return [Int((Double(mass) / 3.0).rounded(.down)) - 2, 0].max()!
}

let fuels = masses.map(calculateFuel)
let fuelRequired = ArrayK(fuels).fold()

print("Pt. 1: \(fuelRequired)")

func calculateFuelRecursive(mass: Int) -> Int {
  let fuelCost = calculateFuel(mass: mass)

  if fuelCost > 0 {
    return fuelCost + calculateFuelRecursive(mass: fuelCost)
  } else {
    return fuelCost
  }
}

let recursiveFuels = masses.map(calculateFuelRecursive)
let recursiveFuelRequired = ArrayK(recursiveFuels).fold()

print("Pt. 2: \(recursiveFuelRequired)")
