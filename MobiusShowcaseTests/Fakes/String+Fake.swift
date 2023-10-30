import Foundation

extension String {

    // MARK: - Type Methods

    static func fake() -> String {
        UUID().uuidString
    }
}

