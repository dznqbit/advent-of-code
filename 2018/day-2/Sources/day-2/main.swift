// https://adventofcode.com/2018/day/2

var lines: [String] = []
while let line = readLine() { lines.append(line) } 

var letterCounts: [[String: Int]] = []

for s in lines {
  var lc: [String: Int] = [:]
  for c in Array(s) {
    // Documentation says defaultValue: ... wtf?
    // https://developer.apple.com/documentation/swift/dictionary/2894528-subscript
    lc[String(c), default: 0] += 1
  }

  letterCounts.append(lc)
}

func countByLetterCount(expectedLetterCount: Int) -> Int {
  return letterCounts.filter { 
    $0.filter { $0.value == expectedLetterCount }.count > 0 
  }.count
}

let exactly2Count = countByLetterCount(expectedLetterCount: 2)
let exactly3Count = countByLetterCount(expectedLetterCount: 3)
let p1 = exactly2Count * exactly3Count
print("Pt 1:", p1)

// Find pair of lines having exactly 1 differing letter
var matchingLines: (String, String)? = nil
let n = lines.count
iLoop: for i in 0..<n {
  let line_i = lines[i]
  jLoop: for j in i..<n {
    let line_j = lines[j]
    var missCount = 0

    kLoop: for k in 0..<line_i.count {
      let ci = String.Index(encodedOffset: k)

      let c_i = line_i[ci]
      let c_j = line_j[ci]

      if c_i != c_j {
        missCount += 1

        if missCount > 1 {
          break kLoop
        }
      }
    }

    if missCount == 1 {
      matchingLines = (line_i, line_j)
    }
  }
}

if let ml = matchingLines {
  // Find common letters between the two
  var commonLetters: [Character] = []
  for i in 0..<ml.0.count {
    let ii = String.Index(encodedOffset: i)
    if ml.0[ii] == ml.1[ii] {
      commonLetters.append(ml.0[ii])
    }
  }

  print("Pt 2:", String(commonLetters))
} else {
  print("Pt 2: No match found :(")
}
