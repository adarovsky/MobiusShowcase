import Foundation

@testable import MobiusShowcase

extension ExampleModel {

    // MARK: - Type Methods

    static func fake(id: UUID = UUID(),
                     content: String = String.fake()) -> ExampleModel {
        ExampleModel(
            id: id,
            content: content
        )
    }
}
