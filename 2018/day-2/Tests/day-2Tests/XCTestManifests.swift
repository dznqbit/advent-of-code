import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(day_2Tests.allTests),
    ]
}
#endif