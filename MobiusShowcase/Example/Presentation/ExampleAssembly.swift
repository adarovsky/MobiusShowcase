import UIKit

@MainActor protocol IExampleAssembly {

    // MARK: - Methods

    func assemble() -> UIViewController
}

final class ExampleAssembly: IExampleAssembly {

    // MARK: - IExamplePresenter

    private let exampleFacade: IExampleFacade
    private let searchingDataSource: ISearchingDataSource
    private let tasksStorageFactory: ITasksStorageFactory

    // MARK: - Initializers

    init(exampleFacade: IExampleFacade,
         searchingDataSource: ISearchingDataSource,
         tasksStorageFactory: ITasksStorageFactory) {
        self.exampleFacade = exampleFacade
        self.searchingDataSource = searchingDataSource
        self.tasksStorageFactory = tasksStorageFactory
    }

    // MARK: - IExampleAssembly

    func assemble() -> UIViewController {
        let presenter = ExamplePresenter(
            exampleFacade: exampleFacade,
            searchingDataSource: searchingDataSource,
            tasksStorageFactory: tasksStorageFactory
        )

        let exampleView = ExampleViewController(
            presenter: presenter
        )

        presenter.view = exampleView

        return exampleView
    }
}
