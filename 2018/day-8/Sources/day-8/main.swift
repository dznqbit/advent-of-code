// http://adventofcode.com/2018/day/8

var numbers: [Int] = []

while let line = readLine() {
  numbers = line.split(separator: " ").map { Int($0) }.filter { $0 != nil }.map { $0! }
}

struct Node : CustomStringConvertible {
    let numbers: ArraySlice<Int>  // Total node input
    let header: ArraySlice<Int>   // Child node count + Metadata Node count
    let metadata: ArraySlice<Int> // Metadata nodes
    let childNodes: [Node]        // Child nodes

    var description: String {
        return "\(header) ... \(metadata)"
    }

    var length: Int {
        return numbers.count
    }
}

func findNode(_ numbers: ArraySlice<Int>) -> Optional<Node> {
    let startIndex = numbers.startIndex
    let header = numbers[startIndex...numbers.index(after: startIndex)]

    guard let childCount = header.first else { return nil }
    guard let metadataCount = header.last else { return nil }

    var childNodes: [Node] = []
    var idx = numbers.index(startIndex, offsetBy: 2)

    if childCount > 0 {
        for i in 0..<childCount {
            guard let childNode = findNode(numbers[idx...]) else { return nil }
            childNodes.append(childNode)
            idx = numbers.index(idx, offsetBy: childNode.length)
        }
    }

    let lastMetadataIndex = numbers.index(idx, offsetBy: metadataCount - 1)
    let metadata = numbers[idx...lastMetadataIndex]

    return Node(
        numbers: numbers[startIndex...lastMetadataIndex],
        header: header,
        metadata: metadata,
        childNodes: childNodes
    )
}

func sumMetadata(_ node: Node) -> Int {
    return (node.childNodes.map { sumMetadata($0) } + node.metadata).reduce(0, +)
}

if let node = findNode(numbers.suffix(numbers.count)) {
    let metadataSum = sumMetadata(node)
    print("Pt 1: \(metadataSum)")
}
