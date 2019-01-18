// https://adventofcode.com/2018/day/4

import Foundation

typealias GuardId = UInt

enum AdventError: Error {
  case keyCollision
  case emptyKey
  case emptyList
  case weirdList
}

enum GuardAction {
  case beginShift
  case fallAsleep
  case wakeUp

  static func parse(_ s: String) -> Optional<GuardAction> {
    if s.hasSuffix("falls asleep") { return .fallAsleep }
    if s.hasSuffix("wakes up") { return .wakeUp }
    if s.hasSuffix("begins shift"){ return .beginShift }

    return nil
  }

  func description() -> String {
    switch self {
      case .beginShift:
        return "begins shift"

      case .fallAsleep:
        return "falls asleep"

      case .wakeUp:
        return "wakes up"
    }
  }
}

struct Timestamp: Hashable, Comparable {
  var date: Date
  // Minutes since midnight. Negative values represent shifts started before midnight
  var minute: Int

  // Parse a Timestamp from a string
  //
  // ex:
  //    1518-11-01 00:00 -> (1518-11-01,  0)
  //    1518-11-01 23:58 -> (1518-11-02, -2)
  //
  static func parse(_ timestampString: String) -> Optional<Timestamp> {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let timestampParts = timestampString.split(separator: " ")
    if timestampParts.count != 2 { return nil }

    let dateString = String(timestampParts[0])
    guard let date = dateFormatter.date(from: dateString) else { return nil }

    let timeStr = String(timestampParts[1])
    let timeParts = timeStr.split(separator: ":")
    if timeParts.count != 2 { return nil }

    guard let hour = Int(timeParts[0]), let minute = Int(timeParts[1]) else { return nil }

    if hour == 23 {
      guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return nil }
      return Timestamp(date: tomorrow, minute: -60 + minute)
    } else {
      return Timestamp(date: date, minute: minute)
    }
  }
}

func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.date == rhs.date ?
      lhs.minute < rhs.minute :
      lhs.date < rhs.date
}

func == (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.date == rhs.date && lhs.minute == rhs.minute
}

extension String {
  init(_ ts: Timestamp) {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    self = String(format: "(%@ %i)", dateFormatter.string(from: ts.date), ts.minute)
  }
}

struct LogEntry {
  var timestamp: Timestamp
  var guardId: Optional<GuardId>
  var action: GuardAction

  // Parse a LogEntry from a string.
  static func parse(_ s: String) -> Optional<LogEntry> {
    let timestampBeginIndex = s.index(s.startIndex, offsetBy: 1)
    let timestampEndIndex = s.index(s.startIndex, offsetBy: 17)
    let timestampString = String(s[timestampBeginIndex..<timestampEndIndex])
    guard let timestamp = Timestamp.parse(timestampString) else { return nil }

    let actionBeginIndex = s.index(s.startIndex, offsetBy: 19)
    let actionString = String(s[actionBeginIndex...])
    guard let action = GuardAction.parse(actionString) else { return nil }

    var guardId: Optional<GuardId> = nil

    if action == .beginShift, let re = try? NSRegularExpression.init(pattern: "Guard #(\\d+)") {
      let range = NSRange(s.startIndex..., in: s)
      guard let match = re.firstMatch(in: s, range: range) else { return nil }
      guard let matchRange = Range(match.range(at: 1), in: s)  else { return nil }
      guardId = GuardId(s[matchRange])
    }

    return LogEntry(timestamp: timestamp, guardId: guardId, action: action)
  }
}

extension String {
  init(_ logEntry: LogEntry) {
    if let guardId = logEntry.guardId {
      self = String(format: "%@ %i %@", String(logEntry.timestamp), guardId, logEntry.action.description())
    } else {
      self = String(format: "%@ %@ %@", String(logEntry.timestamp), "???", logEntry.action.description())
    }
  }
}

var lines: [String] = []
while let line = readLine() { lines.append(line) }

var unsortedLogEntries: [Timestamp:LogEntry] = [:]
for line in lines {
  if let logEntry = LogEntry.parse(line) {
    let timestamp = logEntry.timestamp
    if unsortedLogEntries[timestamp] != nil { throw AdventError.keyCollision }
    unsortedLogEntries[timestamp] = logEntry
  }
}

let sortedTimestamps = unsortedLogEntries.keys.sorted(by: <)
var logEntries: [LogEntry] = []

for ts in sortedTimestamps {
  guard var logEntry = unsortedLogEntries[ts] else { throw AdventError.emptyKey }
  if logEntry.guardId == nil {
    if let lastLogEntry = logEntries.last {
      logEntry.guardId = lastLogEntry.guardId
    } else { throw AdventError.emptyList }
  }

  logEntries.append(logEntry) 
}

var guardMinutesAsleep: [GuardId: UInt] = [:]
var guardSleepByMinute: [GuardId: [Int: UInt]] = [:]

var currentSleepLogEntry: Optional<LogEntry> = nil
for logEntry in logEntries {
  if logEntry.action == .beginShift { continue }
  if logEntry.action == .fallAsleep {  currentSleepLogEntry = logEntry }
  if logEntry.action == .wakeUp {
    guard let sleepingLogEntry = currentSleepLogEntry else { throw AdventError.weirdList }
    guard let guardId = sleepingLogEntry.guardId else { throw AdventError.weirdList }

    let startTime = sleepingLogEntry.timestamp
    let endTime = logEntry.timestamp
    if startTime.date != endTime.date { throw AdventError.weirdList }
    let duration = endTime.minute - startTime.minute

    guardMinutesAsleep[guardId, default: 0] += UInt(duration)
    for minute in startTime.minute..<endTime.minute {
      guardSleepByMinute[guardId, default: [:]][minute, default: 0] += 1
    }

    currentSleepLogEntry = nil
  }
}

if let (sleepiestGuardId, _) = guardMinutesAsleep.max(by: { a, b in a.value < b.value }) {
  guard let guardSleepLog: [Int: UInt] = guardSleepByMinute[sleepiestGuardId] else { throw AdventError.weirdList }
  if let (sleepiestMinute, _) = guardSleepLog.max(by: { a, b in a.value < b.value }) {
    guard let minutes = guardSleepByMinute[sleepiestGuardId] else { throw AdventError.weirdList }
    print("Pt 1:", (Int(sleepiestGuardId) * sleepiestMinute))
  }
}

// Guard with the highest sleep frequency at a particular minute
let guardIdsToSleepiestMinutes = guardSleepByMinute.mapValues { $0.max { a, b in a.value < b.value }! }
if let (sleepyGuardId, tuple) = guardIdsToSleepiestMinutes.max(by: { a, b in a.value.value < b.value.value }) {
  print("Pt 2:", Int(sleepyGuardId) * tuple.key)
}
