import UIKit
import SnapKit
@testable import MobiusShowcase


// MARK: - ExampleView

final class ExampleViewMock: IExampleView {

    // MARK: - startShimmer

    var invokedStartShimmerCount = 0
    var invokedStartShimmer: Bool {
        return invokedStartShimmerCount > 0
    }

    func startShimmer() {
        invokedStartShimmerCount += 1
    }

    // MARK: - stopShimmer

    var invokedStopShimmerCount = 0
    var invokedStopShimmer: Bool {
        return invokedStopShimmerCount > 0
    }

    func stopShimmer() {
        invokedStopShimmerCount += 1
    }

    // MARK: - applyShapshot

    var invokedApplyShapshotCount = 0
    var invokedApplyShapshot: Bool {
        return invokedApplyShapshotCount > 0
    }
    var invokedApplyShapshotParameters: (snapshot: NSDiffableDataSourceSnapshot<Int, UUID>, animated: Bool)?
    var invokedApplyShapshotParametersList: [(snapshot: NSDiffableDataSourceSnapshot<Int, UUID>, animated: Bool)] = []
    lazy var invokedApplyShapshotActor = AutoMockableActor()

    func applyShapshot(_ snapshot: NSDiffableDataSourceSnapshot<Int, UUID>, animated: Bool) async {
        await invokedApplyShapshotActor.withActor { () -> Void in
            invokedApplyShapshotCount += 1
            invokedApplyShapshotParameters = (snapshot, animated)
            invokedApplyShapshotParametersList.append((snapshot, animated))
        }
    }
}
