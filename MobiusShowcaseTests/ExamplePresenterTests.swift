import XCTest
import IdentifiedCollections
import Combine
import CombineSchedulers
import TinkoffConcurrency

@testable import MobiusShowcase

@MainActor
final class ExamplePresenterTests: XCTestCase {

    // MARK: - Dependencies

    private var exampleFacade: ExampleFacadeMock!
    private var searchingDataSource: SearchingDataSourceMock!
    private var tasksStorageFactory: TasksStorageFactoryMock!
    private var tasksStorage: TasksStorageMock!
    private var view: ExampleViewMock!

    // MARK: - UnitTestCase

    override func setUp() {
        super.setUp()

        tasksStorage = TasksStorageMock()
        view = ExampleViewMock()

        exampleFacade = ExampleFacadeMock()
        searchingDataSource = SearchingDataSourceMock()
        tasksStorageFactory = TasksStorageFactoryMock(tasksStorage: tasksStorage)
    }

    override func tearDown() {
        super.tearDown()

        tasksStorage = nil
        view = nil
        exampleFacade = nil
        searchingDataSource = nil
        tasksStorageFactory = nil
    }

    // MARK: - Tests

    func test_examplePresenter_viewDidLoad() async throws {
        // given
        let records = IdentifiedArray(uniqueElements: [
            ExampleViewModel.fake(),
            ExampleViewModel.fake()
        ])

        let searchingDataSourceRecords = TCAsyncChannel<IdentifiedArrayOf<ExampleViewModel>, Never>()

        await searchingDataSource.access {
            $0.stubbedItems = searchingDataSourceRecords.eraseToAnyPublisher()
        }

        let examplePresenter = examplePresenter()

        examplePresenter.view = view

        // when
        examplePresenter.viewDidLoad()

        await tasksStorage.wait(ignoring: "subscribe")

        try await searchingDataSourceRecords.send(records)

        // then
        await XCTAssertTrue(await exampleFacade.invokedLoad)

        await XCTAssertTrue(await searchingDataSource.invokedItemsGetter)

        let viewInvokedApplyShapshotParameters = view.invokedApplyShapshotParameters

        XCTAssertNotNil(viewInvokedApplyShapshotParameters)
        XCTAssertFalse(viewInvokedApplyShapshotParameters!.animated)
        XCTAssertEqual(viewInvokedApplyShapshotParameters!.snapshot.itemIdentifiers(inSection: 0), records.map(\.id))

        for model in records {
            XCTAssertEqual(examplePresenter.item(for: model.id), model)
        }
    }

    func test_examplePresenter_search() async throws {
        let records = IdentifiedArray(uniqueElements: [
            ExampleViewModel.fake(),
            ExampleViewModel.fake()
        ])

        let searchingDataSourceRecords = TCAsyncChannel<IdentifiedArrayOf<ExampleViewModel>, Never>()

        await searchingDataSource.access {
            $0.stubbedItems = searchingDataSourceRecords.eraseToAnyPublisher()
        }

        let examplePresenter = examplePresenter()

        examplePresenter.view = view

        // when
        examplePresenter.viewDidLoad()

        await tasksStorage.wait(ignoring: "subscribe")

        try await searchingDataSourceRecords.send(records)

        examplePresenter.search(string: "abcd")

        // then
        await XCTAssertTrue(await exampleFacade.invokedLoad)

        await XCTAssertTrue(await searchingDataSource.invokedItemsGetter)

        let searchingDataSourceInvokedSetSearchTextParameters = try await XCTUnwrapAsync(
            await searchingDataSource.invokedSetSearchTextParameters
        )

        XCTAssertEqual(searchingDataSourceInvokedSetSearchTextParameters.searchText, "abcd")

        let viewInvokedApplyShapshotParameters = view.invokedApplyShapshotParameters

        XCTAssertNotNil(viewInvokedApplyShapshotParameters)
        XCTAssertFalse(viewInvokedApplyShapshotParameters!.animated)
        XCTAssertEqual(viewInvokedApplyShapshotParameters!.snapshot.itemIdentifiers(inSection: 0), records.map(\.id))

        for model in records {
            XCTAssertEqual(examplePresenter.item(for: model.id), model)
        }
    }

    // MARK: - Private methods

    private func examplePresenter() -> ExamplePresenter {
        ExamplePresenter(
            exampleFacade: exampleFacade,
            searchingDataSource: searchingDataSource,
            tasksStorageFactory: tasksStorageFactory
        )
    }
}
