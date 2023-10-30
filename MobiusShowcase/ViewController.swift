import UIKit
import CombineSchedulers

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func start() {
        let facade = ExampleFacade()
        let backgroundScheduler = DispatchQueue.global().eraseToAnyScheduler()

        let assembly = ExampleAssembly(
            exampleFacade: facade,
            searchingDataSource: SearchingDataSource(
                exampleFacade: facade,
                backgroundScheduler: backgroundScheduler
            ),
            tasksStorageFactory: TasksStorageFactory(
                uuidFactory: UUIDFactory()
            )
        )

        let viewController = assembly.assemble()

        let navigation = UINavigationController(rootViewController: viewController)

        present(navigation, animated: true)
    }
}

