import XCTest
import IdentifiedCollections
import Combine
import CombineSchedulers
import TinkoffConcurrency

@testable import MobiusShowcase

final class SearchingDataSourceTests: XCTestCase {

    // MARK: - Dependencies

    private var exampleFacade: ExampleFacadeMock!

    // MARK: - UnitTestCase

    override func setUp() {
        super.setUp()

        exampleFacade = ExampleFacadeMock()
    }

    override func tearDown() {
        super.tearDown()

        exampleFacade = nil
    }

    // MARK: - Tests

    func test_searchingDataSource_passthrough() async {
        // given
        let first: IdentifiedArray = [ExampleModel.fake()]
        let second: IdentifiedArray = [ExampleModel.fake(), ExampleModel.fake()]
        let subject = PassthroughSubject<IdentifiedArrayOf<ExampleModel>, Never>()

        var cancellables = Set<AnyCancellable>()

        await exampleFacade.access {
            $0.stubbedItems = subject.eraseToAnyPublisher()
        }

        let searchingDataSource = SearchingDataSource(
            exampleFacade: exampleFacade,
            backgroundScheduler: DispatchQueue.test.eraseToAnyScheduler()
        )

        var result: [IdentifiedArrayOf<ExampleModel>] = []

        // when
        await searchingDataSource.items.sink {
            result.append($0)
        }.store(in: &cancellables)

        // then
        XCTAssertEqual(result, [])

        // when
        subject.send(first)

        // then
        XCTAssertEqual(result, [first])

        // when
        subject.send(second)

        // then
        XCTAssertEqual(result, [first, second])
    }

    func test_searchingDataSource_search() async {
        // given
        let first: IdentifiedArray = [ExampleModel.fake(content: "ggg")]
        let second: IdentifiedArray = [ExampleModel.fake(content: "123"), ExampleModel.fake(content: "abc")]
        let subject = PassthroughSubject<IdentifiedArrayOf<ExampleModel>, Never>()

        let backgroundScheduler = DispatchQueue.test

        var cancellables = Set<AnyCancellable>()

        await exampleFacade.access {
            $0.stubbedItems = subject.eraseToAnyPublisher()
        }

        let searchingDataSource = SearchingDataSource(
            exampleFacade: exampleFacade,
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )

        var result: [IdentifiedArrayOf<ExampleModel>] = []

        // when
        await searchingDataSource.items.sink {
            result.append($0)
        }.store(in: &cancellables)

        // then
        XCTAssertEqual(result, [])

        // when
        subject.send(first)
        await searchingDataSource.setSearchText("12")

        // then
        XCTAssertEqual(result, [first])

        // then
        XCTAssertEqual(result, [first])

        // when
        await backgroundScheduler.advance(by: .seconds(0.6))

        // then
        XCTAssertEqual(result, [first, []])

        // when
        subject.send(second)

        // then
        XCTAssertEqual(result, [first, [], [second[0]]])

        // when
        await searchingDataSource.setSearchText("")
        await backgroundScheduler.advance(by: .seconds(0.6))

        // then
        XCTAssertEqual(result, [first, [], [second[0]], second])
    }
}
