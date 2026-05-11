import UIKit

final class P2PViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 56
        static let buttonCornerRadius: CGFloat = 10
        static let buttonFontSize: CGFloat = 18
        static let balanceFontSize: CGFloat = 13
        static let rowHeight: CGFloat = 80
    }

    private let viewModel: P2PViewModel
    private weak var coordinator: P2PCoordinator?

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

    init(viewModel: P2PViewModel, coordinator: P2PCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
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
        bindViewModel()
        viewModel.loadOffers()
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
        fromButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .bold)
        fromButton.setTitleColor(.white, for: .normal)
        fromButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        fromButton.layer.cornerRadius = Constants.buttonCornerRadius
        fromButton.addTarget(self, action: #selector(currencyTapped), for: .touchUpInside)
        fromButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupArrowLabel() {
        arrowLabel.text = "→"
        arrowLabel.font = .systemFont(ofSize: 22)
        arrowLabel.textColor = .systemGray
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupToButton() {
        toButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .bold)
        toButton.setTitleColor(.white, for: .normal)
        toButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        toButton.layer.cornerRadius = Constants.buttonCornerRadius
        toButton.addTarget(self, action: #selector(currencyTapped), for: .touchUpInside)
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

    func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
    }

    func updateUI() {
        fromButton.setTitle(viewModel.fromCurrency, for: .normal)
        toButton.setTitle(viewModel.toCurrency, for: .normal)
        fromBalanceLabel.text = viewModel.fromBalance
        toBalanceLabel.text = viewModel.toBalance

        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            tableView.isHidden = viewModel.offers.isEmpty
            emptyLabel.isHidden = !viewModel.offers.isEmpty
            tableView.reloadData()
        }
    }
}

// MARK: - Actions

private extension P2PViewController {

    @objc func currencyTapped() {
        viewModel.openCurrencyPicker(delegate: self)
    }

    @objc func walletTapped() {
        viewModel.openWallet()
    }
}

// MARK: - CurrencyViewControllerDelegate

extension P2PViewController: CurrencyViewControllerDelegate {

    func didUpdateCurrencyPair(from: String, to: String) {
        viewModel.updatePair(from: from, to: to)
    }
}

// MARK: - UITableViewDataSource

extension P2PViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: P2POfferCell.reuseId, for: indexPath) as? P2POfferCell else {
            return UITableViewCell()
        }
        let offer = viewModel.offers[indexPath.row]
        cell.configure(
            sellerName: offer.sellerName,
            rate: offer.rate,
            reserve: offer.reserve,
            from: viewModel.fromCurrency,
            to: viewModel.toCurrency
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension P2PViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectOffer(viewModel.offers[indexPath.row])
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        viewModel.openSellerInfo(viewModel.offers[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let infoAction = UIContextualAction(style: .normal, title: "Info") { [weak self] _, _, done in
            guard let self = self else { return }
            self.viewModel.openSellerInfo(self.viewModel.offers[indexPath.row])
            done(true)
        }
        infoAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [infoAction])
    }
}
