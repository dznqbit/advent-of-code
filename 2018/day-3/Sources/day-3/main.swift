// https://adventofcode.com/2018/day/3
import Foundation

struct Coords : Hashable { var x: UInt, y: UInt }  
struct Claim {
  var id: UInt

  var x: UInt
  var y: UInt
  var w: UInt
  var h: UInt

  static func parse(claim: String) -> Optional<Claim> {
    // "#1 @ 5,6: 7x8"
    let pattern = "^#(\\d+) @ (\\d+),(\\d+): (\\d+)x(\\d+)$"

    if let regex = try? NSRegularExpression(pattern: pattern) {
      assert(regex.numberOfCaptureGroups == 5)

      let matches = regex.matches(
        in: claim, 
        range: NSRange(claim.startIndex..., in: claim)
      )

      if matches.count == 0 { return nil }
      let match = matches[0]

      let cId = UInt(claim[Range(match.range(at: 1), in: claim)!])!
      let cX  = UInt(claim[Range(match.range(at: 2), in: claim)!])!
      let cY  = UInt(claim[Range(match.range(at: 3), in: claim)!])!
      let cW  = UInt(claim[Range(match.range(at: 4), in: claim)!])!
      let cH  = UInt(claim[Range(match.range(at: 5), in: claim)!])!

      return Claim(id: cId, x: cX, y: cY, w: cW, h: cH)
    }

    return nil
  }
}

var lines: [String] = []
while let line = readLine() { lines.append(line) } 

let claims = lines.compactMap { s in Claim.parse(claim: s) }

var fabricAssignments: Dictionary<Coords, [UInt]> = [:]
for claim in claims { 
  for x in claim.x..<(claim.x+claim.w) {
    for y in claim.y..<(claim.y+claim.h) {
      fabricAssignments[Coords(x: x, y: y), default: []].append(claim.id)
    }
  }
}

var collisions = fabricAssignments.filter { $1.count > 1 }
print("Pt 1:", collisions.count)

var claimIds = Set(claims.map { $0.id })
var collisionIds = collisions.map { $0.value }.joined()
let uniqueCollisionIds = Set(collisionIds)
let uncollidedIds = claimIds.symmetricDifference(uniqueCollisionIds)

if uncollidedIds.count == 1 {
  print("Pt 2:", Array(uncollidedIds)[0]) 
} else {
  print("Pt 2: ???")
}
