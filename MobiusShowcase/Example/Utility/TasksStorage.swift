import Foundation
import Combine

/// Хранилище задач.
///
/// Отменяет добавленные задачи при деинициализации.
public protocol ITasksStorage: AnyObject, Cancellable {

    // MARK: - Properties

    /// Признак отмены.
    var isCancelled: Bool { get }

    // MARK: - Methods

    /// Добавляет задачу и возвращает признак успешности.
    ///
    /// Если задачи были отменены ранее вернётся `false`. В противном случае – `true`.
    ///
    /// Если значение ключа – `nil`, то задача будет добавлена с уникальным сгенерированным ключом без попытки отмены добавленной ранее задачи.
    /// - Parameters:
    ///   - task: Задача.
    ///   - key: Ключ для идентификации задачи.
    @discardableResult func add(_ task: ITask, key: String?) -> Bool

    /// Отменяет задачу и возвращает признак успешности.
    ///
    /// Если задача не найдена или была отменена ранеее вернётся `false`. В противном случае – `true`.
    /// - Parameters:
    ///   - key: Ключ для идентификации задачи.
    @discardableResult func cancel(key: String) -> Bool
}

final class TasksStorage: ITasksStorage {

    // MARK: - Dependencies

    private let uuidFactory: UUIDFactory

    // MARK: - Private Properties

    private let lock = NSLock()

    /// Задачи.
    private var tasks = [String: ITask]()

    /// Признак отмены.
    private var _isCancelled = false

    // MARK: - Initializers

    init(uuidFactory: UUIDFactory) {
        self.uuidFactory = uuidFactory
    }

    // MARK: - Deinitializer

    deinit {
        cancel()
    }

    // MARK: - ITasksStorage

    public var isCancelled: Bool {
        return lock.access { _isCancelled }
    }

    @discardableResult func add(_ task: ITask, key: String?) -> Bool {
        if task.isCancelled {
            return false
        }

        lock.lock()

        if _isCancelled {
            lock.unlock()

            return false
        }

        // Если ключа нет, считаем, что операция уникальная и искать операцию для отмены бесполезно.
        guard let key = key else {
            tasks[uuidFactory.create().uuidString] = task

            lock.unlock()

            return true
        }

        let taskToCancel = tasks[key]

        tasks[key] = task

        lock.unlock()

        taskToCancel?.cancel()

        return true
    }

    @discardableResult func cancel(key: String) -> Bool {
        lock.lock()

        // Если все задачи были отменены ранее, то смысла искать конкретную задачу для отмены нет.
        if _isCancelled {
            lock.unlock()

            return false
        }

        guard let taskToCancel = tasks[key], !taskToCancel.isCancelled else {
            lock.unlock()

            return false
        }

        lock.unlock()

        taskToCancel.cancel()

        return true
    }

    // MARK: - Cancellable

    /// Отменяет задачи.
    ///
    /// Повторный вызов игнорируется.
    func cancel() {
        lock.lock()

        if _isCancelled {
            return lock.unlock()
        }

        _isCancelled = true

        let tasksToCancel = self.tasks.values

        lock.unlock()

        tasksToCancel.forEach { $0.cancel() }
    }
}

extension Task {

    // MARK: - Methods

    @discardableResult public func store(in storage: ITasksStorage, key: String?) -> Bool {
        storage.add(self, key: key)
    }
}
