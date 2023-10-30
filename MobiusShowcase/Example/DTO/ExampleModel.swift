import Foundation

struct ExampleModel: Equatable, Identifiable {

    // MARK: - Properties

    let id: UUID

    let content: String
}

typealias ExampleViewModel = ExampleModel
