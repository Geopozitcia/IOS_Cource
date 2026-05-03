import UIKit

struct P2POffer {
    let sellerName: String
    let rate: Double
    let reserve: Double
}

final class P2PViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 56
        static let buttonCornerRadius: CGFloat = 10
        static let buttonFontSize: CGFloat = 18
        static let balanceFontSize: CGFloat = 13
        static let headerHeight: CGFloat = 130
        static let rowHeight: CGFloat = 80
        static let sellerNames = [
            "CryptoKing", "FastTrader", "P2PMaster",
            "CoinSwap", "SafeExchange", "TrustPeer",
            "QuickDeal", "AlphaTrader", "BitBroker"
        ]
        static let discountRange: ClosedRange<Double> = 0.95...0.99
    }

    private let wallet: Wallet

    private var fromCurrency: String = "USD"
    private var toCurrency: String = "EUR"
    private var offers: [P2POffer] = []
    private var baseRate: Double = 0.0
    private var isLoading: Bool = false

    private let fromButton = UIButton(type: .system)
    private let toButton = UIButton(type: .system)
    private let arrowLabel = UILabel()
    private let fromBalanceLabel = UILabel()
    private let toBalanceLabel = UILabel()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No offers available"
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
        title = "P2P Exchange"
        setupBackground()
        setupSubviews()
        setupConstraints()
        setupNavigationBar()
        updateBalanceLabels()
        loadOffers()
    }
}

// MARK: - Setup

private extension P2PViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    func setupNavigationBar() {
        let walletButton = UIBarButtonItem(
            image: UIImage(systemName: "wallet.pass"),
            style: .plain,
            target: self,
            action: #selector(walletTapped)
        )
        navigationItem.rightBarButtonItem = walletButton
    }

    func setupSubviews() {
        setupFromButton()
        setupArrowLabel()
        setupToButton()
        setupBalanceLabels()
        setupTableView()
        setupLoadingIndicator()

        view.addSubview(fromButton)
        view.addSubview(arrowLabel)
        view.addSubview(toButton)
        view.addSubview(fromBalanceLabel)
        view.addSubview(toBalanceLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)
    }

    func setupFromButton() {
        fromButton.setTitle(fromCurrency, for: .normal)
        fromButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .bold)
        fromButton.setTitleColor(.white, for: .normal)
        fromButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        fromButton.layer.cornerRadius = Constants.buttonCornerRadius
        fromButton.addTarget(self, action: #selector(fromTapped), for: .touchUpInside)
        fromButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupArrowLabel() {
        arrowLabel.text = "→"
        arrowLabel.font = .systemFont(ofSize: 22)
        arrowLabel.textColor = .systemGray
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupToButton() {
        toButton.setTitle(toCurrency, for: .normal)
        toButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .bold)
        toButton.setTitleColor(.white, for: .normal)
        toButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        toButton.layer.cornerRadius = Constants.buttonCornerRadius
        toButton.addTarget(self, action: #selector(toTapped), for: .touchUpInside)
        toButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupBalanceLabels() {
        setupBalanceLabel(fromBalanceLabel)
        setupBalanceLabel(toBalanceLabel)
        toBalanceLabel.textAlignment = .right
    }

    func setupBalanceLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: Constants.balanceFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Constants.rowHeight
        tableView.register(P2POfferCell.self, forCellReuseIdentifier: P2POfferCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupLoadingIndicator() {
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            fromButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            fromButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            fromButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            fromButton.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.38),

            arrowLabel.centerYAnchor.constraint(equalTo: fromButton.centerYAnchor),
            arrowLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            toButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            toButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            toButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            toButton.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.38),

            fromBalanceLabel.topAnchor.constraint(equalTo: fromButton.bottomAnchor, constant: 6),
            fromBalanceLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),

            toBalanceLabel.topAnchor.constraint(equalTo: toButton.bottomAnchor, constant: 6),
            toBalanceLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            tableView.topAnchor.constraint(equalTo: fromBalanceLabel.bottomAnchor, constant: Constants.padding),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

// MARK: - Data

private extension P2PViewController {

    func loadOffers() {
        isLoading = true
        emptyLabel.isHidden = true
        loadingIndicator.startAnimating()
        tableView.isHidden = true

        NetworkService.shared.fetchRates(for: fromCurrency) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.loadingIndicator.stopAnimating()

            switch result {
            case .success(let rates):
                if let rate = rates.first(where: { $0.toCurrency == self.toCurrency })?.rate {
                    self.baseRate = rate
                    self.generateOffers(from: rate)
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                } else {
                    self.showEmpty()
                }
            case .failure:
                self.showEmpty()
            }
        }
    }

    func generateOffers(from baseRate: Double) {
        offers = Constants.sellerNames.map { name in
            let discount = Double.random(in: Constants.discountRange)
            let rate = baseRate * discount
            let reserve = Double.random(in: 100...10000)
            return P2POffer(sellerName: name, rate: rate, reserve: reserve)
        }.sorted { $0.rate > $1.rate }
    }

    func showEmpty() {
        tableView.isHidden = true
        emptyLabel.isHidden = false
    }

    func updateBalanceLabels() {
        let fromBalance = wallet.balance(for: fromCurrency)
        let toBalance = wallet.balance(for: toCurrency)
        fromBalanceLabel.text = "Balance: \(String(format: "%.2f", fromBalance)) \(fromCurrency)"
        toBalanceLabel.text = "Balance: \(String(format: "%.2f", toBalance)) \(toCurrency)"
    }

    func showExchangeAlert(for offer: P2POffer) {
        let alert = UIAlertController(
            title: offer.sellerName,
            message: "Rate: \(String(format: "%.4f", offer.rate))\nEnter amount in \(fromCurrency)",
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.keyboardType = .decimalPad
            field.placeholder = "Amount"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Exchange", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let amount = Double(text) else { return }
            self.executeExchange(amount: amount, offer: offer)
        })
        present(alert, animated: true)
    }

    func executeExchange(amount: Double, offer: P2POffer) {
        NetworkService.shared.executeExchange(
            from: fromCurrency,
            to: toCurrency,
            amount: amount
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let received):
                self.wallet.deduct(amount: amount, currency: self.fromCurrency)
                self.wallet.deposit(amount: received, currency: self.toCurrency)
                self.updateBalanceLabels()
                self.showResult(success: true, message: "You received \(String(format: "%.4f", received)) \(self.toCurrency)")
            case .failure(let error):
                self.showResult(success: false, message: error.description)
            }
        }
    }

    func showResult(success: Bool, message: String) {
        let alert = UIAlertController(
            title: success ? "Success" : "Exchange Failed",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Actions

private extension P2PViewController {

    @objc func fromTapped() {
        let currencyVC = CurrencyViewController()
        currencyVC.setInitialPair(from: fromCurrency, to: toCurrency)
        currencyVC.delegate = self
        currencyVC.mode = .apiOnly
        let nav = UINavigationController(rootViewController: currencyVC)
        present(nav, animated: true)
    }

    @objc func toTapped() {
        let currencyVC = CurrencyViewController()
        currencyVC.setInitialPair(from: fromCurrency, to: toCurrency)
        currencyVC.delegate = self
        currencyVC.mode = .apiOnly
        let nav = UINavigationController(rootViewController: currencyVC)
        present(nav, animated: true)
    }

    @objc func walletTapped() {
        let walletVC = WalletViewController(wallet: wallet)
        present(walletVC, animated: true)
    }
}

// MARK: - CurrencyViewControllerDelegate

extension P2PViewController: CurrencyViewControllerDelegate {

    func didUpdateCurrencyPair(from: String, to: String) {
        fromCurrency = from
        toCurrency = to
        fromButton.setTitle(from, for: .normal)
        toButton.setTitle(to, for: .normal)
        updateBalanceLabels()
        loadOffers()
    }
}

// MARK: - UITableViewDataSource

extension P2PViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: P2POfferCell.reuseId, for: indexPath) as? P2POfferCell else {
            return UITableViewCell()
        }
        let offer = offers[indexPath.row]
        cell.configure(sellerName: offer.sellerName, rate: offer.rate, reserve: offer.reserve, from: fromCurrency, to: toCurrency)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension P2PViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showExchangeAlert(for: offers[indexPath.row])
    }
}
