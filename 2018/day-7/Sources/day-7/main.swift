// http://adventofcode.com/2018/day/7

import Foundation

enum AdventError: Error {
  case alreadyInList
}

func parse(_ s: String) -> Optional<(Character, Character)> {
  let pattern = "Step ([A-Z]) must be finished before step ([A-Z]) can begin."
  guard let re = try? NSRegularExpression.init(pattern: pattern) else { return nil }

  let range = NSRange(s.startIndex..., in: s)
  guard let match = re.firstMatch(in: s, range: range) else { return nil }
  guard let conditionRange = Range(match.range(at: 1), in: s) else { return nil }
  guard let taskRange = Range(match.range(at: 2), in: s)  else { return nil }

  let condition = Character(String(s[conditionRange]))
  let task = Character(String(s[taskRange]))

  return (condition, task)
}

class Task: CustomStringConvertible, Hashable {
  let name: Character
  var active: Bool
  var complete: Bool
  var dependencies: [Task]

  init(_ n: Character) {
    name = n
    active = false
    complete = false
    dependencies = []
  }

  public static func == (a: Task, b: Task) -> Bool {
    return a.name == b.name && a.complete == b.complete && a.dependencies == b.dependencies
  }

  // should get the job done
  var hashValue: Int { return name.hashValue }

  var description:String {
    return "(\(name))"
  }

  var incomplete:Bool { return !complete }
  var completionTime:Int {
    let asciiValue = Int(name.unicodeScalars.filter { $0.isASCII }.first!.value)
    return asciiValue - 65
  }
}

func nextIncompleteTask(_ tasks: [Task]) -> Optional<Task> {
  for task in tasks {
    if task.complete || task.active { continue }
    if !task.dependencies.contains(where: { $0.incomplete }) { return task }
  }

  return nil
}

var tasksByName: [Character:Task] = [:]
var tasks: [Task] = []

while let line = readLine(), let dependency = parse(line) {
  let parentTask = tasksByName[dependency.0, default: Task(dependency.0)]
  let childTask = tasksByName[dependency.1, default: Task(dependency.1)]
  childTask.dependencies.append(parentTask)

  for t in [parentTask, childTask] {
    tasksByName[t.name] = t
    if !tasks.contains(where: { $0.name == t.name }) { tasks.append(t) }
  }
}

tasks.sort(by: { a, b in a.name < b.name })
var taskNames: [Character] = []

while let task = nextIncompleteTask(tasks) {
  task.complete = true
  taskNames.append(task.name)
}

print("Pt. 1:", String(taskNames))

// Reset
for task in tasks { task.complete = false }
taskNames.removeAll()

var seconds = 0
let baseTaskTime = 60
let workerCount = 5
var activeTasks: [Task:Int] = [:]

while tasks.contains(where: { $0.incomplete }) {
  for task in activeTasks.keys {
    let taskTime = activeTasks[task]! - 1

    if taskTime <= 0 {
      task.active = false
      task.complete = true
      taskNames.append(task.name)
      activeTasks.removeValue(forKey: task)
    } else {
      activeTasks[task] = taskTime
    }
  }

  while let task = nextIncompleteTask(tasks) {
    if activeTasks.count == workerCount { break }

    task.active = true
    activeTasks[task] = baseTaskTime + task.completionTime + 1
  }

  let tts = activeTasks.keys.map { String($0.name) }.joined(separator: ", ")
  seconds += 1
}

print("Pt. 2:", seconds - 1)
