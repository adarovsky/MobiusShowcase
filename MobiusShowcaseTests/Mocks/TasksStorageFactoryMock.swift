import XCTest
import MobiusShowcase

final class TasksStorageFactoryMock: ITasksStorageFactory {

    // MARK: - Private Properties

    private let tasksStorage: ITasksStorage

    // MARK: - Initializers

    init(tasksStorage: ITasksStorage) {
        self.tasksStorage = tasksStorage
    }

    // MARK: - ITasksStorageFactory

    var invokedCreateCount = 0
    var invokedCreate: Bool {
        return invokedCreateCount > 0
    }

    func create() -> ITasksStorage {
        invokedCreateCount += 1

        return tasksStorage
    }
}
