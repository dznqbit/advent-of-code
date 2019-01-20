import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(day_7Tests.allTests),
    ]
}
#endif