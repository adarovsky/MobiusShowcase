import UIKit
import SnapKit

@MainActor
protocol IExampleView: AnyObject {

    // MARK: - Methods

    func startShimmer()

    func stopShimmer()

    func applyShapshot(_ snapshot: NSDiffableDataSourceSnapshot<Int, UUID>, animated: Bool) async
}

final class ExampleViewController: UIViewController, IExampleView {

    // MARK: - Dependencies

    private let presenter: IExamplePresenter

    // MARK: - Initializers

    init(presenter: IExamplePresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Properties

    private lazy var dataSource: UITableViewDiffableDataSource<Int, UUID> = {
        let dataSource = UITableViewDiffableDataSource<Int, UUID>(tableView: tableView) { [weak self, presenter] tableView, indexPath, itemID -> UITableViewCell? in
            guard let item = presenter.item(for: itemID) else {
                return nil
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

            cell.textLabel?.text = item.content

            return cell
        }

        dataSource.defaultRowAnimation = .fade

        return dataSource
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.allowsSelection = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50

        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never

        return tableView
    }()

    private lazy var shimmer: UIActivityIndicatorView = {
        let shimmer = UIActivityIndicatorView()

        shimmer.style = .medium
        shimmer.hidesWhenStopped = true

        return shimmer
    }()

    private lazy var appendFakesButton = UIBarButtonItem(
        title: "Add Fakes",
        style: .plain,
        target: self,
        action: #selector(appendFakes)
    )

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()

        searchBar.placeholder = "Search"
        searchBar.delegate = self

        return searchBar
    }()

    // MARK: - IExampleView

    func startShimmer() {
        shimmer.startAnimating()
    }

    func stopShimmer() {
        shimmer.stopAnimating()
    }

    func applyShapshot(_ snapshot: NSDiffableDataSourceSnapshot<Int, UUID>, animated: Bool) async {
        await withCheckedContinuation { continuation in
            dataSource.apply(snapshot, animatingDifferences: animated) {
                continuation.resume()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground

        presenter.viewDidLoad()

        addSubviews()

        navigationItem.title = "Пример"
    }

    override func viewDidDisappear(_ animated: Bool) {
        presenter.viewDidDisappear()
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(shimmer)

        navigationItem.rightBarButtonItem = appendFakesButton

        tableView.tableHeaderView = searchBar

        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        searchBar.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalToSuperview()
        }

        shimmer.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    @IBAction private func appendFakes() {
        presenter.appendFakes()
    }
}

extension ExampleViewController: UISearchBarDelegate {

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(string: searchText)
    }
}
