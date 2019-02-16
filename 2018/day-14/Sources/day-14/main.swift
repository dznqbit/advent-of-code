// http://adventofcode.com/2018/day/14
import Foundation

guard let input = readLine() else { exit(1) }

class RecipeFinder : CustomStringConvertible {
  var recipes: [Int]
  var indexes: [Int]

  init(recipes: [Int], indexes: [Int]) {
    self.recipes = recipes
    self.indexes = indexes
  }

  func next() {
    let values = indexes.map { recipes[$0] }.reduce(0, +)
    let chars: [Character] = Array(String(values))
    let ints: [Int] = chars.compactMap { Int(String($0)) }

    for i in ints { recipes.append(i) }
    self.indexes = indexes.map { ($0 + recipes[$0] + 1) % recipeCount }
  }

  var description:String {
    return recipes.enumerated().map { (idx, v) in 
      if indexes[0] == idx { return "(\(v))" }
      if indexes[1] == idx { return "[\(v)]" }

      return " \(v) "
    }.joined(separator: "")
  }

  var recipeCount:Int {
    return recipes.count
  }
}

func findPt1(_ input: Int) -> Int {
  let recipeFinder = RecipeFinder(recipes: [3, 7], indexes: [0, 1])

  for _ in 0...(input + 10) { recipeFinder.next() }
  return Int(recipeFinder.recipes[input..<(input + 10)].map { String($0) }.joined())!
}

func findPt2(_ inputString: String) -> Int {
  let inputString = String(input)
  let inputLength = inputString.count
  let inputArray = Array(inputString).map { Int(String($0))! }
  let recipeFinder = RecipeFinder(recipes: [3, 7], indexes: [0, 1])

  for _ in 0...50_000_000 {
    recipeFinder.next()
    let recipeCount = recipeFinder.recipes.count
    if recipeCount < inputLength { continue }

    for idx in recipeFinder.indexes {

      let _ = [0, idx - inputLength].max()!
      let r = [recipeFinder.recipeCount - 1, idx + inputLength].min()!

      for anchor in stride(from: r, to: idx, by: -1) {
        var broken = false

        for inputIdx in stride(from: inputLength - 1, to: -1, by: -1) {
          if inputArray[inputIdx] != recipeFinder.recipes[anchor - (inputLength - inputIdx)] {
            broken = true
            break
          }
        }

        if !broken {
          return anchor - inputLength
        }
      }
    }
  }

  return -1
}

let pt1 = findPt1(Int(input)!)
print("Pt. 1: \(pt1)")

let pt2 = findPt2(input)
print("Pt. 2: \(pt2)")
