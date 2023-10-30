import XCTest
import Combine
import MobiusShowcase

final class TasksStorageMock: ITasksStorage {

    // MARK: - Private Properties

    /// Задачи, завершение которых необходимо дождаться.
    private var tasksToWait = [(task: ITask, key: String?)]()

    // MARK: - ICancellable

    var invokedCancelCount = 0
    var invokedCancel: Bool {
        return invokedCancelCount > 0
    }

    func cancel() {
        invokedCancelCount += 1
    }

    // MARK: - ITasksStorage

    var invokedIsCancelledGetter: Bool {
        invokedIsCancelledGetterCount > 0
    }

    var invokedIsCancelledGetterCount = 0
    var stubbedIsCancelled: Bool!
    var stubbedIsCancelledList: [Bool]?

    var isCancelled: Bool {
        invokedIsCancelledGetterCount += 1

        if let stubbedIsCancelledList = stubbedIsCancelledList {
            return stubbedIsCancelledList[invokedIsCancelledGetterCount - 1]
        }

        return stubbedIsCancelled
    }

    var invokedAddCount = 0
    var invokedAdd: Bool {
        return invokedAddCount > 0
    }

    var invokedAddParameters: (task: ITask, key: String?)?
    var invokedAddParametersList: [(task: ITask, key: String?)] = []
    var stubbedAddResult: Bool! = true
    var stubbedAddResultList: [Bool]?

    @discardableResult func add(_ task: ITask, key: String?) -> Bool {
        invokedAddCount += 1
        invokedAddParameters = (task, key)
        invokedAddParametersList.append((task, key))

        tasksToWait.append((task, key))

        if let stubbedAddResultList = stubbedAddResultList {
            return stubbedAddResultList[invokedAddCount - 1]
        }

        return stubbedAddResult
    }

    var invokedCancelKeyCount = 0
    var invokedCancelKey: Bool {
        return invokedCancelKeyCount > 0
    }

    var invokedCancelKeyParameters: (key: String, Void)?
    var invokedCancelKeyParametersList: [(key: String, Void)] = []
    var stubbedCancelKeyResult: Bool! = true
    var stubbedCancelKeyResultList: [Bool]?

    @discardableResult func cancel(key: String) -> Bool {
        invokedCancelKeyCount += 1
        invokedCancelKeyParameters = (key, ())
        invokedCancelKeyParametersList.append((key, ()))

        if let stubbedCancelKeyResultList = stubbedCancelKeyResultList {
            return stubbedCancelKeyResultList[invokedCancelKeyCount - 1]
        }

        return true
    }

    // MARK: - Methods

    /// Ожидает завершения всех добавленных с момента последнего ожидания задач.
    func wait() async {
        for record in tasksToWait {
            await record.task.wait()
        }

        tasksToWait = []
    }

    /// Ожидает завершения всех добавленных с момента последнего ожидания задач.
    func wait(ignoring: String...) async {
        let predicate = { (key: String?) -> Bool in
            guard let key = key else { return false }

            return ignoring.contains(key)
        }

        for record in tasksToWait where !predicate(record.key) {
            await record.task.wait()
        }

        tasksToWait = tasksToWait.filter { predicate($1) }
    }
}
