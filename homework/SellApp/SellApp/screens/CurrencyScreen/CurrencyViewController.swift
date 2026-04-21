import UIKit

protocol CurrencyViewControllerDelegate: AnyObject {
    func didUpdateCurrencyPair(from: String, to: String)
}

final class CurrencyViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let cellSize: CGFloat = 72
        static let cellSpacing: CGFloat = 8
        static let filterHeight: CGFloat = 36
        static let favoritesViewHeight: CGFloat = 44
    }

    weak var delegate: CurrencyViewControllerDelegate?

    private let viewModel = CurrencyViewModel()

    private let fromButton = UIButton(type: .system)
    private let toButton = UIButton(type: .system)
    private let arrowLabel = UILabel()
    private let rateLabel = UILabel()
    private let timerLabel = UILabel()

    private let amountTextField = UITextField()
    private let resultLabel = UILabel()

    private let favoritesFilterView = FavoritesFilterView()

    private let filterStack = UIStackView()
    private let allFilterButton = UIButton(type: .system)
    private let fiatFilterButton = UIButton(type: .system)
    private let cryptoFilterButton = UIButton(type: .system)

    private let emptyFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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

    // начальная пара передаётся снаружи до показа экрана
    func setInitialPair(from: String, to: String) {
        viewModel.setInitialPair(from: from, to: to)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSubviews()
        setupConstraints()
        setupViewModel()
    }
}

// MARK: - Setup

private extension CurrencyViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    func setupSubviews() {
        setupFromButton()
        setupArrowLabel()
        setupToButton()
        setupRateLabel()
        setupTimerLabel()
        setupAmountTextField()
        setupResultLabel()
        setupFavoritesFilterView()
        setupFilterButtons()
        setupCollectionView()

        view.addSubview(fromButton)
        view.addSubview(arrowLabel)
        view.addSubview(toButton)
        view.addSubview(rateLabel)
        view.addSubview(timerLabel)
        view.addSubview(amountTextField)
        view.addSubview(resultLabel)
        view.addSubview(favoritesFilterView)
        view.addSubview(filterStack)
        view.addSubview(collectionView)
        view.addSubview(emptyFavoritesLabel)
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

    func setupRateLabel() {
        rateLabel.textColor = .systemGray
        rateLabel.font = .systemFont(ofSize: 14)
        rateLabel.textAlignment = .center
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTimerLabel() {
        timerLabel.textColor = .systemGray
        timerLabel.font = .systemFont(ofSize: 13)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupAmountTextField() {
        amountTextField.placeholder = "Enter amount"
        amountTextField.keyboardType = .decimalPad
        amountTextField.textColor = .white
        amountTextField.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        amountTextField.layer.cornerRadius = 8
        amountTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        amountTextField.leftViewMode = .always
        amountTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter amount",
            attributes: [.foregroundColor: UIColor.systemGray]
        )
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupResultLabel() {
        resultLabel.textColor = .white
        resultLabel.font = .systemFont(ofSize: 14)
        resultLabel.textAlignment = .center
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupFavoritesFilterView() {
        favoritesFilterView.delegate = self
        favoritesFilterView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupFilterButtons() {
        setupFilterButton(allFilterButton, title: "All")
        setupFilterButton(fiatFilterButton, title: "Fiat")
        setupFilterButton(cryptoFilterButton, title: "Crypto")

        allFilterButton.addTarget(self, action: #selector(filterAllTapped), for: .touchUpInside)
        fiatFilterButton.addTarget(self, action: #selector(filterFiatTapped), for: .touchUpInside)
        cryptoFilterButton.addTarget(self, action: #selector(filterCryptoTapped), for: .touchUpInside)

        filterStack.axis = .horizontal
        filterStack.distribution = .fillEqually
        filterStack.spacing = 8
        filterStack.addArrangedSubview(allFilterButton)
        filterStack.addArrangedSubview(fiatFilterButton)
        filterStack.addArrangedSubview(cryptoFilterButton)
        filterStack.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupFilterButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
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

            rateLabel.topAnchor.constraint(equalTo: fromButton.bottomAnchor, constant: 10),
            rateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            rateLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            timerLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 4),
            timerLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            timerLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            amountTextField.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: Constants.padding),
            amountTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            amountTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),

            resultLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 6),
            resultLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            resultLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            favoritesFilterView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: Constants.padding),
            favoritesFilterView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            favoritesFilterView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            favoritesFilterView.heightAnchor.constraint(equalToConstant: Constants.favoritesViewHeight),

            filterStack.topAnchor.constraint(equalTo: favoritesFilterView.bottomAnchor, constant: 8),
            filterStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            filterStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            filterStack.heightAnchor.constraint(equalToConstant: Constants.filterHeight),

            collectionView.topAnchor.constraint(equalTo: filterStack.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            emptyFavoritesLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyFavoritesLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 40)
        ])
    }

    func setupViewModel() {
        viewModel.onUpdate = {
            self.updateUI()
        }
        viewModel.onCurrencyPairChanged = { [weak self] from, to in
            self?.delegate?.didUpdateCurrencyPair(from: from, to: to)
        }
        viewModel.start()
        updateUI()
    }

    func updateUI() {
        fromButton.setTitle(viewModel.fromCurrency, for: .normal)
        toButton.setTitle(viewModel.toCurrency, for: .normal)
        rateLabel.text = "Rate: \(viewModel.rateText)"
        timerLabel.text = "Update in: \(viewModel.secondsUntilRefresh)s"

        if viewModel.inputAmount > 0 {
            resultLabel.text = "= \(viewModel.convertedAmount) \(viewModel.toCurrency)"
        } else {
            resultLabel.text = ""
        }

        if viewModel.selectedSlot == 0 {
            fromButton.layer.borderWidth = 2
            fromButton.layer.borderColor = UIColor.systemBlue.cgColor
            toButton.layer.borderWidth = 0
        } else {
            toButton.layer.borderWidth = 2
            toButton.layer.borderColor = UIColor.systemBlue.cgColor
            fromButton.layer.borderWidth = 0
        }

        allFilterButton.backgroundColor = viewModel.selectedFilter == .all
            ? .systemBlue : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        fiatFilterButton.backgroundColor = viewModel.selectedFilter == .fiat
            ? .systemBlue : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        cryptoFilterButton.backgroundColor = viewModel.selectedFilter == .crypto
            ? .systemBlue : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)

        let isEmpty = !viewModel.hasCurrencies && viewModel.showFavoritesOnly
        emptyFavoritesLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty

        collectionView.reloadData()
    }
}

// MARK: - Actions

private extension CurrencyViewController {

    @objc func fromTapped() {
        viewModel.selectSlot(0)
    }

    @objc func toTapped() {
        viewModel.selectSlot(1)
    }

    @objc func filterAllTapped() {
        viewModel.selectFilter(.all)
    }

    @objc func filterFiatTapped() {
        viewModel.selectFilter(.fiat)
    }

    @objc func filterCryptoTapped() {
        viewModel.selectFilter(.crypto)
    }

    @objc func amountChanged() {
        viewModel.updateInputAmount(amountTextField.text ?? "")
    }
}

// MARK: - FavoritesFilterViewDelegate

extension CurrencyViewController: FavoritesFilterViewDelegate {

    func didToggleFavoritesFilter(isOn: Bool) {
        viewModel.setFavoritesFilter(isOn)
    }
}

// MARK: - CurrencyCellDelegate

extension CurrencyViewController: CurrencyCellDelegate {

    func didToggleFavorite(currency: String) {
        viewModel.toggleFavorite(currency)
    }
}

// MARK: - UICollectionViewDataSource

extension CurrencyViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currencies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.reuseId, for: indexPath) as? CurrencyCell else {
            return UICollectionViewCell()
        }
        let currency = viewModel.currencies[indexPath.item]
        let isSelected = currency == viewModel.fromCurrency || currency == viewModel.toCurrency
        cell.configure(with: currency, isDisabled: viewModel.isDisabled(currency), isSelected: isSelected, isFavorite: viewModel.isFavorite(currency))
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CurrencyViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = viewModel.currencies[indexPath.item]
        guard !viewModel.isDisabled(currency) else { return }

        if let cell = collectionView.cellForItem(at: indexPath) as? CurrencyCell {
            cell.animateSelection()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.viewModel.selectCurrency(currency)
        }
    }
}
