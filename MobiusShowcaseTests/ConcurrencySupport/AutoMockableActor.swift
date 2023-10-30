actor AutoMockableActor {
    func withActor<T>(body: () -> T) -> T {
        body()
    }
}

extension Actor {

    // MARK: - Methods

    func access<T>(body: (isolated Self) -> T) -> T {
        body(self)
    }

    func access<T>(body: (isolated Self) throws -> T) rethrows -> T {
        try body(self)
    }
}
