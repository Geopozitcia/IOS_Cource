import UIKit

final class TradeViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let pairButtonHeight: CGFloat = 50
        static let pairButtonCornerRadius: CGFloat = 10
        static let pairButtonFontSize: CGFloat = 17
        static let runButtonHeight: CGFloat = 48
        static let runButtonCornerRadius: CGFloat = 12
        static let runButtonFontSize: CGFloat = 16
        static let runButtonTitle = "Run command"
        static let imageViewHeight: CGFloat = 120
        static let imageViewPlaceholder = "UIImageView"
        static let productName = "Some Product for sale, Type A, Black"
        static let productPrice = "12 990 $"
        static let productOldPrice = "19 990 $"
        static let deliveryText = "Delivery: tomorrow"
        static let ratingText = "4.4 ★"
        static let reviewsText = "1513 reviews"
        static let emptyText = "No data"
        static let containerHeight: CGFloat = 56
        static let ratingFontSize: CGFloat = 15
        static let emptyLabelTopOffset: CGFloat = 40
        static let nameFontSize: CGFloat = 17
        static let priceFontSize: CGFloat = 22
        static let oldPriceFontSize: CGFloat = 15
    }

    private let viewModel: TradeViewModel
    private weak var coordinator: TradeCoordinator?

    private let darkColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    private let cardColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
    private let innerColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    private let imageViewColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)

    private let currencyPairButton = UIButton(type: .system)
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let oldPriceLabel = UILabel()
    private let containerView = UIView()
    private let innerView = UIView()
    private let deliveryLabel = UILabel()
    private let ratingView = UIView()
    private let hStack = UIStackView()
    private let ratingLabel = UILabel()
    private let reviewsLabel = UILabel()
    private let runButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.emptyText
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: TradeViewModel, coordinator: TradeCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSubviews()
        setupConstraints()
        setupNavigationBar()
        bindViewModel()
        updateUI()
    }
}

// MARK: - Setup

private extension TradeViewController {

    func setupBackground() {
        view.backgroundColor = darkColor
    }

    func setupNavigationBar() {
        let trashButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain, target: self, action: #selector(trashTapped)
        )
        let shuffleButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain, target: self, action: #selector(shuffleTapped)
        )
        let chartButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar"),
            style: .plain, target: self, action: #selector(chartTapped)
        )
        let walletButton = UIBarButtonItem(
            image: UIImage(systemName: "wallet.pass"),
            style: .plain, target: self, action: #selector(walletTapped)
        )
        // новая кнопка
        let heatmapButton = UIBarButtonItem(
            image: UIImage(systemName: "square.grid.3x3.fill"),
            style: .plain, target: self, action: #selector(heatmapTapped)
        )

        navigationItem.leftBarButtonItem = trashButton
        navigationItem.rightBarButtonItems = [shuffleButton, chartButton, walletButton, heatmapButton]
    }

    func setupSubviews() {
        setupCurrencyPairButton()
        setupImageView()
        setupNameLabel()
        setupPriceLabel()
        setupOldPriceLabel()
        setupContainerView()
        setupRatingView()
        setupRunButton()
        setupTableView()
        setupLoadingIndicator()

        view.addSubview(currencyPairButton)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(priceLabel)
        view.addSubview(oldPriceLabel)
        view.addSubview(containerView)
        view.addSubview(ratingView)
        view.addSubview(runButton)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)
    }

    func setupCurrencyPairButton() {
        currencyPairButton.backgroundColor = cardColor
        currencyPairButton.layer.cornerRadius = Constants.pairButtonCornerRadius
        currencyPairButton.titleLabel?.font = .systemFont(ofSize: Constants.pairButtonFontSize, weight: .semibold)
        currencyPairButton.setTitleColor(.white, for: .normal)
        currencyPairButton.addTarget(self, action: #selector(pairButtonTapped), for: .touchUpInside)
        currencyPairButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupImageView() {
        imageView.backgroundColor = imageViewColor
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let placeholderLabel = UILabel()
        placeholderLabel.text = Constants.imageViewPlaceholder
        placeholderLabel.textColor = .systemGray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    func setupNameLabel() {
        nameLabel.text = Constants.productName
        nameLabel.numberOfLines = 2
        nameLabel.font = .systemFont(ofSize: Constants.nameFontSize, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupPriceLabel() {
        priceLabel.text = Constants.productPrice
        priceLabel.font = .systemFont(ofSize: Constants.priceFontSize, weight: .bold)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupOldPriceLabel() {
        let strikeAttr = NSAttributedString(string: Constants.productOldPrice, attributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemGray
        ])
        oldPriceLabel.attributedText = strikeAttr
        oldPriceLabel.font = .systemFont(ofSize: Constants.oldPriceFontSize)
        oldPriceLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupContainerView() {
        containerView.backgroundColor = cardColor
        containerView.layer.cornerRadius = Constants.pairButtonCornerRadius
        containerView.translatesAutoresizingMaskIntoConstraints = false

        innerView.backgroundColor = innerColor
        innerView.layer.cornerRadius = 8
        innerView.translatesAutoresizingMaskIntoConstraints = false

        deliveryLabel.text = Constants.deliveryText
        deliveryLabel.textAlignment = .center
        deliveryLabel.font = .systemFont(ofSize: Constants.oldPriceFontSize)
        deliveryLabel.textColor = .white
        deliveryLabel.translatesAutoresizingMaskIntoConstraints = false

        innerView.addSubview(deliveryLabel)
        containerView.addSubview(innerView)
    }

    func setupRatingView() {
        ratingView.backgroundColor = cardColor
        ratingView.layer.cornerRadius = Constants.pairButtonCornerRadius
        ratingView.layer.borderWidth = 1
        ratingView.layer.borderColor = UIColor.systemGray.cgColor
        ratingView.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.text = Constants.ratingText
        ratingLabel.font = .systemFont(ofSize: Constants.ratingFontSize, weight: .medium)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        reviewsLabel.text = Constants.reviewsText
        reviewsLabel.font = .systemFont(ofSize: Constants.ratingFontSize, weight: .medium)
        reviewsLabel.textColor = .white
        reviewsLabel.textAlignment = .center
        reviewsLabel.translatesAutoresizingMaskIntoConstraints = false

        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 8
        hStack.addArrangedSubview(ratingLabel)
        hStack.addArrangedSubview(reviewsLabel)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        ratingView.addSubview(hStack)
    }

    func setupRunButton() {
        runButton.setTitle(Constants.runButtonTitle, for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = Constants.runButtonCornerRadius
        runButton.titleLabel?.font = .systemFont(ofSize: Constants.runButtonFontSize, weight: .semibold)
        runButton.addTarget(self, action: #selector(runTapped), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(DayResultCell.self, forCellReuseIdentifier: DayResultCell.reuseId)
        tableView.dataSource = self
        tableView.isHidden = true
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
            currencyPairButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            currencyPairButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            currencyPairButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            currencyPairButton.heightAnchor.constraint(equalToConstant: Constants.pairButtonHeight),

            imageView.topAnchor.constraint(equalTo: currencyPairButton.bottomAnchor, constant: Constants.padding),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            nameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),

            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),

            containerView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            containerView.heightAnchor.constraint(equalToConstant: Constants.containerHeight),

            innerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            innerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            innerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            innerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            deliveryLabel.topAnchor.constraint(equalTo: innerView.topAnchor),
            deliveryLabel.bottomAnchor.constraint(equalTo: innerView.bottomAnchor),
            deliveryLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
            deliveryLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),

            ratingView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12),
            ratingView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            ratingView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            hStack.topAnchor.constraint(equalTo: ratingView.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: -12),

            runButton.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 12),
            runButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            runButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            runButton.heightAnchor.constraint(equalToConstant: Constants.runButtonHeight),

            tableView.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: Constants.emptyLabelTopOffset),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: Constants.emptyLabelTopOffset)
        ])
    }

    func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
    }

    func updateUI() {
        currencyPairButton.setTitle(viewModel.pairTitle, for: .normal)

        if viewModel.isLoading {
            runButton.isEnabled = false
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true
        } else {
            runButton.isEnabled = true
            loadingIndicator.stopAnimating()
            let hasResults = !viewModel.dayResults.isEmpty
            tableView.isHidden = !hasResults
            emptyLabel.isHidden = hasResults
            tableView.reloadData()
        }
    }
}

// MARK: - Actions

private extension TradeViewController {

    @objc func pairButtonTapped() {
        viewModel.openCurrencyPicker(delegate: self)
    }

    @objc func trashTapped() {
        viewModel.reset()
    }

    @objc func shuffleTapped() {
        viewModel.shuffle()
    }

    @objc func runTapped() {
        viewModel.runBots()
    }

    @objc func chartTapped() {
        viewModel.openChart()
    }

    @objc func walletTapped() {
        viewModel.openWallet()
    }
    
    @objc func heatmapTapped() {
        viewModel.openHeatmap() 
    }
}

// MARK: - CurrencyViewControllerDelegate

extension TradeViewController: CurrencyViewControllerDelegate {

    func didUpdateCurrencyPair(from: String, to: String) {
        viewModel.updatePair(from: from, to: to)
    }
}

// MARK: - UITableViewDataSource

extension TradeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dayResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayResultCell.reuseId, for: indexPath) as? DayResultCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.dayResults[indexPath.row])
        return cell
    }
}
