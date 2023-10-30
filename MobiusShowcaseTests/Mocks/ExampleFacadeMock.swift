import Foundation
import IdentifiedCollections
import Combine
import Fakery
@testable import MobiusShowcase


// MARK: - ExampleFacade

actor ExampleFacadeMock: IExampleFacade {

    // MARK: - items

    var invokedItemsGetter: Bool {
        invokedItemsGetterCount > 0
    }
    var invokedItemsGetterCount = 0

    var stubbedItems: AnyPublisher<IdentifiedArrayOf<ExampleModel>, Never>!
    var stubbedItemsList: [AnyPublisher<IdentifiedArrayOf<ExampleModel>, Never>]?

    var items: AnyPublisher<IdentifiedArrayOf<ExampleModel>, Never> {
        invokedItemsGetterCount += 1

        if let stubbedItemsList = stubbedItemsList {
            return stubbedItemsList[invokedItemsGetterCount - 1]
        }

        return stubbedItems
    }

    // MARK: - load

    var invokedLoadCount = 0
    var invokedLoad: Bool {
        return invokedLoadCount > 0
    }
    var stubbedLoadThrowableError: Error?
    var stubbedLoadThrowableErrorList: [Error?]?

    func load() async throws {
        invokedLoadCount += 1

        if let stubbedLoadThrowableErrorList = stubbedLoadThrowableErrorList,
           let error = stubbedLoadThrowableErrorList[invokedLoadCount - 1] {
            throw error
        }
        if let error = stubbedLoadThrowableError {
            throw error
        }
    }

    // MARK: - appendFakes

    var invokedAppendFakesCount = 0
    var invokedAppendFakes: Bool {
        return invokedAppendFakesCount > 0
    }

    func appendFakes() async {
        invokedAppendFakesCount += 1
    }
}
