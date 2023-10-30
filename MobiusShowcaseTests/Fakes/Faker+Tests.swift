import Fakery

extension Faker {

    // MARK: - Type Properties

    static var `default`: Faker = Faker()

    static var ru = Faker(locale: "ru")
}
