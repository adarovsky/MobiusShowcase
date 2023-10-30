import Foundation
import Combine
import IdentifiedCollections
import CombineSchedulers

protocol ISearchingDataSource: Actor {
    var items: AnyPublisher<IdentifiedArrayOf<ExampleViewModel>, Never> { get async }

    func setSearchText(_ searchText: String)
}

actor SearchingDataSource: ISearchingDataSource {

    // MARK: - Dependencies

    private let exampleFacade: IExampleFacade
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Initializers

    init(exampleFacade: IExampleFacade,
         backgroundScheduler: AnySchedulerOf<DispatchQueue>) {
        self.exampleFacade = exampleFacade
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - IExampleViewModelDataSource

    var items: AnyPublisher<IdentifiedArrayOf<ExampleViewModel>, Never> {
        get async {
            let models = await exampleFacade.items

            let search = searchText
                .debounce(for: 0.5, scheduler: backgroundScheduler)
                .merge(with: searchText.prefix(1))
                .removeDuplicates()

            let filteredModels = models.combineLatest(search) { models, search in
                models.filter {
                    search.isEmpty || $0.content.localizedCaseInsensitiveContains(search)
                }
            }

            return filteredModels.eraseToAnyPublisher()
        }
    }

    func setSearchText(_ searchText: String) {
        self.searchText.value = searchText
    }

    // MARK: - Private Properties

    private var searchText = CurrentValueSubject<String, Never>("")
}
