import Foundation
import IdentifiedCollections
import UIKit
import TinkoffConcurrency

protocol IExamplePresenter: AnyObject {

    // MARK: - Methods

    func viewDidLoad()

    func viewDidDisappear()

    @MainActor
    func item(for id: UUID) -> ExampleViewModel?

    func appendFakes()

    func search(string: String)
}

final class ExamplePresenter: IExamplePresenter {

    // MARK: - Dependencies

    private let exampleFacade: IExampleFacade
    private let searchingDataSource: ISearchingDataSource
    private let tasksStorageFactory: ITasksStorageFactory

    weak var view: IExampleView?

    // MARK: - Initializers

    init(exampleFacade: IExampleFacade,
         searchingDataSource: ISearchingDataSource,
         tasksStorageFactory: ITasksStorageFactory) {
        self.exampleFacade = exampleFacade
        self.searchingDataSource = searchingDataSource
        self.tasksStorageFactory = tasksStorageFactory
    }

    // MARK: - IExamplePresenter

    func viewDidLoad() {
        Task {
            try await loadData()
        }.store(in: tasksStorage, key: "load")

        Task { [weak self, searchingDataSource] in
            let values = await searchingDataSource.items
            for await values in values.asyncValues {
                await self?.updateItems(values)
            }
        }.store(in: tasksStorage, key: "subscribe")
    }

    func viewDidDisappear() {
        tasksStorage.cancel()
    }

    func item(for id: UUID) -> ExampleViewModel? {
        items[id: id]
    }

    func appendFakes() {
        Task {
            await exampleFacade.appendFakes()
        }.store(in: tasksStorage, key: #function)
    }

    func search(string: String) {
        Task {
            await searchingDataSource.setSearchText(string)
        }.store(in: tasksStorage, key: #function)
    }
    
    // MARK: - Private Properties

    @MainActor
    private var items: IdentifiedArrayOf<ExampleViewModel> = []

    private lazy var tasksStorage = tasksStorageFactory.create()

    // MARK: - Private Methods

    @MainActor
    private func loadData() async throws {
        view?.startShimmer()
        defer { view?.stopShimmer() }

        try await exampleFacade.load()
    }

    @MainActor
    private func updateCache(with newItems: IdentifiedArrayOf<ExampleViewModel>) -> IdentifiedArrayOf<ExampleViewModel> {
        let old = items

        items = newItems

        return old
    }

    private func updateItems(_ items: IdentifiedArrayOf<ExampleViewModel>) async {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()

        let sortedIdentifiers = items.map(\.id)

        snapshot.appendSections([0])
        snapshot.appendItems(sortedIdentifiers, toSection: 0)

        let old = await updateCache(with: items)

        let animated = !old.ids.isDisjoint(with: sortedIdentifiers)

        if let view = view {
            await view.applyShapshot(snapshot, animated: animated)
        }
    }
}
