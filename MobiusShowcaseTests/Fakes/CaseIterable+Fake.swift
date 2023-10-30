extension CaseIterable {

    // MARK: - Type Methods

    static func fake() -> AllCases.Element {
        self.allCases.randomElement()!
    }

    static func fake(isIncluded: (AllCases.Element) -> Bool) -> AllCases.Element {
        self.allCases.filter(isIncluded).randomElement()!
    }
}
