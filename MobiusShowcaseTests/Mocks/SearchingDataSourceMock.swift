import Foundation
import Combine
import IdentifiedCollections
import CombineSchedulers
@testable import MobiusShowcase


// MARK: - SearchingDataSource

actor SearchingDataSourceMock: ISearchingDataSource {

    // MARK: - items

    var invokedItemsGetter: Bool {
        invokedItemsGetterCount > 0
    }
    var invokedItemsGetterCount = 0

    var stubbedItems: AnyPublisher<IdentifiedArrayOf<ExampleViewModel>, Never>!
    var stubbedItemsList: [AnyPublisher<IdentifiedArrayOf<ExampleViewModel>, Never>]?

    var items: AnyPublisher<IdentifiedArrayOf<ExampleViewModel>, Never> {
        invokedItemsGetterCount += 1

        if let stubbedItemsList = stubbedItemsList {
            return stubbedItemsList[invokedItemsGetterCount - 1]
        }

        return stubbedItems
    }

    // MARK: - setSearchText

    var invokedSetSearchTextCount = 0
    var invokedSetSearchText: Bool {
        return invokedSetSearchTextCount > 0
    }
    var invokedSetSearchTextParameters: (searchText: String, Void)?
    var invokedSetSearchTextParametersList: [(searchText: String, Void)] = []

    func setSearchText(_ searchText: String) {
        invokedSetSearchTextCount += 1
        invokedSetSearchTextParameters = (searchText, ())
        invokedSetSearchTextParametersList.append((searchText, ()))
    }
}
