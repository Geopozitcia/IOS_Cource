import UIKit

final class WalletViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let cellHeight: CGFloat = 64
        static let cornerRadius: CGFloat = 10
        static let titleFontSize: CGFloat = 15
        static let balanceFontSize: CGFloat = 17
        static let creditFontSize: CGFloat = 12
    }

    private let wallet: Wallet

    private let tableView = UITableView()
    private var currencies: [String] = []

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No wallet data yet.\nRun the bot first."
        label.numberOfLines = 2
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        setupBackground()
        setupSubviews()
        setupConstraints()
        loadData()
    }
}

// MARK: - Setup

private extension WalletViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    func setupSubviews() {
        setupTableView()
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
    }

    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(WalletCell.self, forCellReuseIdentifier: WalletCell.reuseId)
        tableView.dataSource = self
        tableView.rowHeight = Constants.cellHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func loadData() {
        let snapshot = wallet.snapshot()
        currencies = snapshot.keys.sorted()
        let hasData = !currencies.isEmpty
        tableView.isHidden = !hasData
        emptyLabel.isHidden = hasData
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension WalletViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletCell.reuseId, for: indexPath) as? WalletCell else {
            return UITableViewCell()
        }
        let currency = currencies[indexPath.row]
        let balance = wallet.balance(for: currency)
        let credit = wallet.credit(for: currency)
        cell.configure(currency: currency, balance: balance, credit: credit)
        return cell
    }
}
