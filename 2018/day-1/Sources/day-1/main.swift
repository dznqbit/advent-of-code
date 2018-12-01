var changes: [Int] = []

while let line = readLine() { 
  if let change = Int(line) {
    changes.append(change)
  }
}

// Part 1: Just sum up the changes.
let sumOfChanges = changes.reduce(0, { s, c in s + c })
print("Pt 1:", sumOfChanges)

// Part 2: Cycle through the change list until we hit a repeated frequency.
var frequencies: Set = [0]
var frequency = 0
var changeIndex = 0
var firstRepeatedFrequency: Int? = nil

while firstRepeatedFrequency == nil {
  frequency += changes[changeIndex] 

  if frequencies.contains(frequency) {
    firstRepeatedFrequency = frequency
  }

  frequencies.insert(frequency)
  changeIndex = (changeIndex + 1) % changes.count
}

print("Pt 2:", firstRepeatedFrequency!)
