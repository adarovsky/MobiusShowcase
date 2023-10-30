import XCTest

public func XCTAssertTrue(_ expression: @autoclosure () async throws -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async {
    do {
        let e = try await expression();

        { XCTAssertTrue(e, message(), file: file, line: line) }()
    } catch {
        XCTFail("Unexpected exception: \(error)")
    }
}

