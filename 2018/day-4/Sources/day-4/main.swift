// https://adventofcode.com/2018/day/4
import Foundation

enum GuardAction {
  case beginShift
  case fallsAsleep
  case wakesUp
}

struct LogEntry {
  var time: Date
  var guardId: UInt
  var action: GuardAction
}

func parseTimestamp(_ line: String) -> Optional<(Date, String)> {
    if let closeBracketIndex = line.firstIndex(of: "]") {
      let dateString = String(line.prefix(through: closeBracketIndex))
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "[yyyy-MM-dd HH:mm]"

      return (
        dateFormatter.date(from: dateString)!, 
        String(line.suffix(from: line.index(closeBracketIndex, offsetBy: 2)))
      )
    } else {
      return nil
    }
}

// Build up action list
var lines: [String] = []
while let line = readLine() { lines.append(line) } 

var logEntries: [LogEntry] = []
for line in lines {
  if let (timestamp, str) = parseTimestamp(line) {
    switch str {
      case "falls asleep":
        let guardId = logEntries.last!.guardId
        logEntries.append(LogEntry(time: timestamp, guardId: guardId, action: .fallsAsleep))

      case "wakes up":
        let guardId = logEntries.last!.guardId
        logEntries.append(LogEntry(time: timestamp, guardId: guardId, action: .wakesUp))

      default:
        let hashIndex = str.firstIndex(of: "#")!
        let idIndex = str.index(hashIndex, offsetBy: 1)
        let guardId = UInt(str.suffix(from: idIndex).prefix(while: { "0"..."9" ~= $0 }))!
        logEntries.append(LogEntry(time: timestamp, guardId: guardId, action: .beginShift))
    }
  }
}

for logEntry in logEntries {
  print(logEntry)
}
