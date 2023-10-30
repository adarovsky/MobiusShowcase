public protocol ITasksStorageFactory: AnyObject, Sendable {

    // MARK: - Methods

    func create() -> ITasksStorage
}

final class TasksStorageFactory: ITasksStorageFactory {

    // MARK: - Dependencies

    private let uuidFactory: UUIDFactory

    // MARK: - Initializers

    init(uuidFactory: UUIDFactory) {
        self.uuidFactory = uuidFactory
    }

    // MARK: - ITasksStorageFactory

    func create() -> ITasksStorage {
        TasksStorage(uuidFactory: uuidFactory)
    }
}
