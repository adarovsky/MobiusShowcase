import Foundation
import IdentifiedCollections
import Combine
import Fakery

protocol IExampleFacade: Actor {

    // MARK: - Properties

    var items: AnyPublisher<IdentifiedArrayOf<ExampleModel>, Never> { get }

    // MARK: - Methods

    func load() async throws

    func appendFakes() async
}


actor ExampleFacade: IExampleFacade {

    // MARK: - Private Properties

    let faker = Faker()

    // MARK: - IExampleFacade

    var items: AnyPublisher<IdentifiedArrayOf<ExampleModel>, Never> { $_items.eraseToAnyPublisher() }

    func load() async throws {
        _items = IdentifiedArray(uniqueElements: ExampleModel.cachedItems)

        try await Task.sleep(nanoseconds: 5_000_000_000)

        _items = IdentifiedArray(uniqueElements: ExampleModel.loadedItems)
    }

    func appendFakes() async {
        let contents = (0 ..< 100).map { _ in
            ExampleModel(id: UUID(), content: faker.lorem.sentence())
        }

        _items.append(contentsOf: contents)
    }

    // MARK: - Private Properties

    @Published
    private var _items: IdentifiedArrayOf<ExampleModel> = []
}

private extension ExampleModel {
    static let cachedItems: [ExampleModel] = [
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, content: "Cached 1"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, content: "Cached 2"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, content: "Cached 3"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, content: "Cached 4")
    ]

    static let loadedItems: [ExampleModel] = [
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, content: "Loaded Item 1"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, content: "Cached 3"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!, content: "Loaded Item 2"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, content: "Cached 4"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!, content: "Loaded Item 3"),
        ExampleModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, content: "Cached 2"),
    ]
}
