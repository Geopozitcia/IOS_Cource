import UIKit

final class QuickCurrencyViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let cellSize: CGFloat = 72
        static let cellSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 60
        static let showAllButtonHeight: CGFloat = 48
    }

    weak var delegate: CurrencyViewControllerDelegate?

    private let service = CurrencyService.shared

    private var fromCurrency: String = "USD"
    private var toCurrency: String = "BTC"
    private var selectedSlot: Int = 0

    private var displayedCurrencies: [String] = []

    private let fromButton = UIButton(type: .system)
    private let toButton = UIButton(type: .system)
    private let arrowLabel = UILabel()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet. Tap 'Show All' to pick currencies."
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let showAllButton = UIButton(type: .system)

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Constants.cellSize, height: Constants.cellSize)
        layout.minimumInteritemSpacing = Constants.cellSpacing
        layout.minimumLineSpacing = Constants.cellSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Constants.padding,
            left: Constants.padding,
            bottom: Constants.padding,
            right: Constants.padding
        )
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    func setInitialPair(from: String, to: String) {
        fromCurrency = from
        toCurrency = to
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quick Select"
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        loadCurrencies()
        setupSubviews()
        setupConstraints()
        updateUI()
    }
}

// MARK: - Setup

private extension QuickCurrencyViewController {

    func loadCurrencies() {
        let favorites = Array(service.favorites)
        if favorites.isEmpty {
            // if no favorites, show 10 random currencies
            displayedCurrencies = Array(service.currencies.shuffled().prefix(10))
        } else {
            displayedCurrencies = favorites.sorted()
        }
    }

    func setupSubviews() {
        setupFromButton()
        setupArrowLabel()
        setupToButton()
        setupShowAllButton()
        setupCollectionView()

        view.addSubview(fromButton)
        view.addSubview(arrowLabel)
        view.addSubview(toButton)
        view.addSubview(showAllButton)
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
    }

    func setupFromButton() {
        fromButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        fromButton.setTitleColor(.white, for: .normal)
        fromButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        fromButton.layer.cornerRadius = 10
        fromButton.addTarget(self, action: #selector(fromTapped), for: .touchUpInside)
        fromButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupArrowLabel() {
        arrowLabel.text = "→"
        arrowLabel.textColor = .systemGray
        arrowLabel.font = .systemFont(ofSize: 22)
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupToButton() {
        toButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        toButton.setTitleColor(.white, for: .normal)
        toButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        toButton.layer.cornerRadius = 10
        toButton.addTarget(self, action: #selector(toTapped), for: .touchUpInside)
        toButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupShowAllButton() {
        showAllButton.setTitle("Show All", for: .normal)
        showAllButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        showAllButton.setTitleColor(.white, for: .normal)
        showAllButton.layer.cornerRadius = 12
        showAllButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        showAllButton.addTarget(self, action: #selector(showAllTapped), for: .touchUpInside)
        showAllButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            fromButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            fromButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            fromButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            fromButton.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.35),

            arrowLabel.centerYAnchor.constraint(equalTo: fromButton.centerYAnchor),
            arrowLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            toButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            toButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            toButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            toButton.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.35),

            showAllButton.topAnchor.constraint(equalTo: fromButton.bottomAnchor, constant: Constants.padding),
            showAllButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            showAllButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            showAllButton.heightAnchor.constraint(equalToConstant: Constants.showAllButtonHeight),

            collectionView.topAnchor.constraint(equalTo: showAllButton.bottomAnchor, constant: Constants.padding),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 40),
            emptyLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            emptyLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding)
        ])
    }

    func updateUI() {
        fromButton.setTitle(fromCurrency, for: .normal)
        toButton.setTitle(toCurrency, for: .normal)

        if selectedSlot == 0 {
            fromButton.layer.borderWidth = 2
            fromButton.layer.borderColor = UIColor.systemBlue.cgColor
            toButton.layer.borderWidth = 0
        } else {
            toButton.layer.borderWidth = 2
            toButton.layer.borderColor = UIColor.systemBlue.cgColor
            fromButton.layer.borderWidth = 0
        }

        emptyLabel.isHidden = !displayedCurrencies.isEmpty
        collectionView.isHidden = displayedCurrencies.isEmpty
        collectionView.reloadData()
    }

    func isDisabled(_ currency: String) -> Bool {
        return selectedSlot == 0 ? currency == toCurrency : currency == fromCurrency
    }
}

// MARK: - Actions

private extension QuickCurrencyViewController {

    @objc func fromTapped() {
        selectedSlot = 0
        updateUI()
    }

    @objc func toTapped() {
        selectedSlot = 1
        updateUI()
    }

    @objc func showAllTapped() {
        // close this screen and push full currency screen into the navigation stack
        let currencyVC = CurrencyViewController()
        currencyVC.setInitialPair(from: fromCurrency, to: toCurrency)
        currencyVC.delegate = delegate
        navigationController?.pushViewController(currencyVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension QuickCurrencyViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedCurrencies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.reuseId, for: indexPath) as? CurrencyCell else {
            return UICollectionViewCell()
        }
        let currency = displayedCurrencies[indexPath.item]
        let isSelected = currency == fromCurrency || currency == toCurrency
        cell.configure(with: currency, isDisabled: isDisabled(currency), isSelected: isSelected, isFavorite: service.isFavorite(currency))
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension QuickCurrencyViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = displayedCurrencies[indexPath.item]
        guard !isDisabled(currency) else { return }

        if selectedSlot == 0 {
            guard currency != toCurrency else { return }
            fromCurrency = currency
        } else {
            guard currency != fromCurrency else { return }
            toCurrency = currency
        }

        delegate?.didUpdateCurrencyPair(from: fromCurrency, to: toCurrency)
        updateUI()
    }
}
