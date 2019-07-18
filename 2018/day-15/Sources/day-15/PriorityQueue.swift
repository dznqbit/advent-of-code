typealias Priority = UInt
struct PriorityQueue<T> { 
  var data: [Priority:[T]]

  init() { 
    self.data = [:]
  }

  mutating func insert(_ data: T, priority: Priority) {
    self.data[priority, default: []].append(data)
  }

  mutating func shift() -> T? {
    guard let minKey = data.keys.sorted().first,
          var keyData = data[minKey]
          else { return nil }

    let value = keyData.removeFirst()

    if keyData.isEmpty {
      self.data.removeValue(forKey: minKey)
    } else {
      self.data[minKey] = keyData
    }

    return value
  }
}

extension PriorityQueue where T : CustomStringConvertible {
  var description:String {
    return data.description
  }
}
