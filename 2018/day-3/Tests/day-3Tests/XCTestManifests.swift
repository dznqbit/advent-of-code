import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(day_3Tests.allTests),
    ]
}
#endif