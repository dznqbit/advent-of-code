// http://adventofcode.com/2018/day/9

import Foundation
import Darwin.ncurses

typealias Marble = Int

func parseGame(_ s: String) -> Optional<(Int, Int)> {
  let pattern = "(\\d+) players; last marble is worth (\\d+) points"
  guard let re = try? NSRegularExpression.init(pattern: pattern) else { return nil }

  let range = NSRange(s.startIndex..., in: s)
  guard let match = re.firstMatch(in: s, range: range) else { return nil }
  guard let playerCountRange = Range(match.range(at: 1), in: s) else { return nil }
  guard let pointRange = Range(match.range(at: 2), in: s)  else { return nil }

  if let playerCount = Int(String(s[playerCountRange])), let maxMarbleValue = Int(String(s[pointRange])) {
    return (playerCount, maxMarbleValue)
  }

  return nil
}

class MarbleGame : CustomStringConvertible {
  let maxMarbleValue: Int
  let playerCount: Int

  var marbles: [Marble]
  var playerScores: [Int:Int]
  var currentPlayer: Optional<Int>
  var currentMarbleIndex: Int
  var nextMarbleValue: Int

  init(playerCount: Int, maxMarbleValue: Int) {
    marbles = [0]
    marbles.reserveCapacity(maxMarbleValue)

    playerScores = [:]
    nextMarbleValue = 1
    self.maxMarbleValue = maxMarbleValue
    self.playerCount = playerCount

    currentPlayer = nil
    currentMarbleIndex = 0
  }

  func tick() {
    if let cp = currentPlayer {
      currentPlayer = (cp + 1) % playerCount
    } else {
      currentPlayer = 0
    }

    if nextMarbleValue % 23 == 0 {
      currentMarbleIndex = (marbleCount + currentMarbleIndex - 7) % marbleCount
      let removedMarble = marbles.remove(at: currentMarbleIndex)
      playerScores[currentPlayer!, default: 0] += nextMarbleValue + removedMarble
    } else {
      let insertMarbleIndex = (currentMarbleIndex + 2) % marbles.count
      if insertMarbleIndex == 0 {
        marbles.append(nextMarbleValue)
        currentMarbleIndex = marbles.count - 1
      } else {
        marbles.insert(nextMarbleValue, at: insertMarbleIndex)
        currentMarbleIndex = insertMarbleIndex
      }
    }

    nextMarbleValue += 1
  }

  var marbleCount: Int { return marbles.count }
  var active: Bool { return nextMarbleValue <= maxMarbleValue }

  var description: String {
    let player = currentPlayer == nil ? "-" : String(currentPlayer! + 1)
    let marbleList = marbles.enumerated()
      .map { (idx, v) in idx == currentMarbleIndex ? "(\(v))" : String(v) }
      .joined(separator: " ")

    return "{\(nextMarbleValue)/\(maxMarbleValue)} [\(player)\(playerCount)] \(marbleList)"
  }
}

if let line = readLine(), let (playerCount, maxMarbleValue) = parseGame(line) {
  let game = MarbleGame(playerCount: playerCount, maxMarbleValue: maxMarbleValue)
  while game.active { game.tick() }
  if let (_, score) = game.playerScores.max(by: { a, b in a.value < b.value }) {
    print("Pt. 1: \(score)")
  }

  let game2 = MarbleGame(playerCount: playerCount, maxMarbleValue: maxMarbleValue * 100)
  while game2.active {
    game2.tick()
    if game2.nextMarbleValue % 1000 == 0 {
      print("\(game2.nextMarbleValue)/\(game2.maxMarbleValue)")
    }
  }
  if let (_, score) = game2.playerScores.max(by: { a, b in a.value < b.value }) {
    print("Pt. 2: \(score)")
  }
}
