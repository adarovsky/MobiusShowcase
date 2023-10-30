import struct Foundation.UUID

/// Фабрика универсального уникального идентификатора.
public protocol IUUIDFactory: AnyObject, Sendable {

    // MARK: - Methods

    /// Возвращает универсальный уникальный идентификатор.
    func create() -> UUID
}

final class UUIDFactory: IUUIDFactory {

    // MARK: - IUUIDFactory

    func create() -> UUID {
        UUID()
    }
}
