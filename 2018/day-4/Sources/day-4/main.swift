// https://adventofcode.com/2018/day/4
import Foundation
var lines: [String] = []
while let line = readLine() { lines.append(line) } 
print(lines)

enum GuardAction {
  case beginShift
  case fallsAsleep
  case wakesUp
}

struct LogEntry {
  var time: Date
  var guardId: UInt
  var action: GuardAction

  static func parse(line: String) -> Optional<LogEntry> {
    return nil
  }
}
