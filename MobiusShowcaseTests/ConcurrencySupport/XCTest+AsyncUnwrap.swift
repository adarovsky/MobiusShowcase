import XCTest

public func XCTUnwrapAsync<T>(_ expression: @autoclosure () async throws -> T?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async throws -> T {
    let result = try await expression()

    return try XCTUnwrap(result, message(), file: file, line: line)
}
