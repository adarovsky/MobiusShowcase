import Combine

public protocol ITask: Cancellable {

    // MARK: - Properties

    var isCancelled: Bool { get }

    // MARK: - Methods

    func wait() async
}

extension Task: ITask {

    // MARK: - ITask

    public func wait() async {
        _ = await self.result
    }
}
