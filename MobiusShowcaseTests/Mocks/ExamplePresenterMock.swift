import Foundation
import IdentifiedCollections
import UIKit
import TinkoffConcurrency
@testable import MobiusShowcase

// MARK: - ExamplePresenter

final class ExamplePresenterMock: IExamplePresenter {

    // MARK: - viewDidLoad

    var invokedViewDidLoadCount = 0
    var invokedViewDidLoad: Bool {
        return invokedViewDidLoadCount > 0
    }

    func viewDidLoad() {
        invokedViewDidLoadCount += 1
    }

    // MARK: - viewDidDisappear

    var invokedViewDidDisappearCount = 0
    var invokedViewDidDisappear: Bool {
        return invokedViewDidDisappearCount > 0
    }

    func viewDidDisappear() {
        invokedViewDidDisappearCount += 1
    }

    // MARK: - item

    var invokedItemCount = 0
    var invokedItem: Bool {
        return invokedItemCount > 0
    }
    var invokedItemParameters: (id: UUID, Void)?
    var invokedItemParametersList: [(id: UUID, Void)] = []
    var stubbedItemResult: ExampleViewModel?
    var stubbedItemResultList: [ExampleViewModel?]?

    @MainActor
    func item(for id: UUID) -> ExampleViewModel? {
        invokedItemCount += 1
        invokedItemParameters = (id, ())
        invokedItemParametersList.append((id, ()))

        if let stubbedItemResultList = stubbedItemResultList {
            return stubbedItemResultList[invokedItemCount - 1]
        }

        return stubbedItemResult
    }

    // MARK: - appendFakes

    var invokedAppendFakesCount = 0
    var invokedAppendFakes: Bool {
        return invokedAppendFakesCount > 0
    }

    func appendFakes() {
        invokedAppendFakesCount += 1
    }

    // MARK: - search

    var invokedSearchCount = 0
    var invokedSearch: Bool {
        return invokedSearchCount > 0
    }
    var invokedSearchParameters: (string: String, Void)?
    var invokedSearchParametersList: [(string: String, Void)] = []

    func search(string: String) {
        invokedSearchCount += 1
        invokedSearchParameters = (string, ())
        invokedSearchParametersList.append((string, ()))
    }
}
