import UIKit

final class ViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let pairButtonHeight: CGFloat = 50
        static let runButtonHeight: CGFloat = 48
    }

    private let darkColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    private let cardColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
    private let innerColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

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
    private let emptyLabel = UILabel()

    private var trades: [TradeRecord] = []
    private let bot = TradingBot()

    private var fromCurrency: String = "USD"
    private var toCurrency: String = "BTC"
    private let chartVC = ChartViewController()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSubviews()
        setupConstraints()
        setupNavigationBar()
        updatePairButton()
    }
}

// MARK: - Setup

private extension ViewController {

    func setupBackground() {
        view.backgroundColor = darkColor
    }

    func setupNavigationBar() {
        let trashButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(trashTapped)
        )
        let shuffleButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(shuffleTapped)
        )
        let chartButton = UIBarButtonItem( //
            image: UIImage(systemName: "chart.bar"),
            style: .plain,
            target: self,
            action: #selector(chartTapped)
        )
        navigationItem.leftBarButtonItem = trashButton
        navigationItem.rightBarButtonItem = shuffleButton
        navigationItem.rightBarButtonItems = [shuffleButton, chartButton]
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
        setupEmptyLabel()

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
    }

    func setupCurrencyPairButton() {
        currencyPairButton.backgroundColor = cardColor
        currencyPairButton.layer.cornerRadius = 10
        currencyPairButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        currencyPairButton.setTitleColor(.white, for: .normal)
        currencyPairButton.addTarget(self, action: #selector(pairButtonTapped), for: .touchUpInside)
        currencyPairButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupImageView() {
        imageView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let placeholderLabel = UILabel()
        placeholderLabel.text = "UIImageView"
        placeholderLabel.textColor = .systemGray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    func setupNameLabel() {
        nameLabel.text = "Some Product for sale, Type A, Black"
        nameLabel.numberOfLines = 2
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupPriceLabel() {
        priceLabel.text = "12 990 $"
        priceLabel.font = .systemFont(ofSize: 22, weight: .bold)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupOldPriceLabel() {
        let strikeAttr = NSAttributedString(string: "19 990 $", attributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemGray
        ])
        oldPriceLabel.attributedText = strikeAttr
        oldPriceLabel.font = .systemFont(ofSize: 15)
        oldPriceLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupContainerView() {
        containerView.backgroundColor = cardColor
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false

        innerView.backgroundColor = innerColor
        innerView.layer.cornerRadius = 8
        innerView.translatesAutoresizingMaskIntoConstraints = false

        deliveryLabel.text = "Delivery: tomorrow"
        deliveryLabel.textAlignment = .center
        deliveryLabel.font = .systemFont(ofSize: 14)
        deliveryLabel.textColor = .white
        deliveryLabel.translatesAutoresizingMaskIntoConstraints = false

        innerView.addSubview(deliveryLabel)
        containerView.addSubview(innerView)
    }

    func setupRatingView() {
        ratingView.backgroundColor = cardColor
        ratingView.layer.cornerRadius = 10
        ratingView.layer.borderWidth = 1
        ratingView.layer.borderColor = UIColor.systemGray.cgColor
        ratingView.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.text = "4.4 ★"
        ratingLabel.font = .systemFont(ofSize: 15, weight: .medium)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        reviewsLabel.text = "1513 reviews"
        reviewsLabel.font = .systemFont(ofSize: 15, weight: .medium)
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
        runButton.setTitle("Run command", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = 12
        runButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        runButton.addTarget(self, action: #selector(runTapped), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(TradeCell.self, forCellReuseIdentifier: TradeCell.reuseId)
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupEmptyLabel() {
        emptyLabel.text = "No data"
        emptyLabel.textColor = .systemGray
        emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
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
            imageView.heightAnchor.constraint(equalToConstant: 160),

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
            containerView.heightAnchor.constraint(equalToConstant: 56),

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
            emptyLabel.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 60)
        ])
    }

    func updatePairButton() {
        currencyPairButton.setTitle("\(fromCurrency)  →  \(toCurrency)", for: .normal)
    }

    func resetTradingState() {
        trades = []
        tableView.isHidden = true
        emptyLabel.isHidden = false
        tableView.reloadData()
        chartVC.resetCandles()
    }
}

// MARK: - Actions

private extension ViewController {

    @objc func pairButtonTapped() {
        let quickVC = QuickCurrencyViewController()
        quickVC.setInitialPair(from: fromCurrency, to: toCurrency)
        quickVC.delegate = self
        let nav = UINavigationController(rootViewController: quickVC)
        present(nav, animated: true)
    }

    @objc func trashTapped() {
        resetTradingState()
    }

    @objc func shuffleTapped() {
        let currencies = CurrencyService.shared.currencies
        guard currencies.count >= 2 else { return }
        let from = currencies.randomElement()!
        var to = currencies.randomElement()!
        while to == from {
            to = currencies.randomElement()!
        }
        fromCurrency = from
        toCurrency = to
        updatePairButton()
        resetTradingState()
    }

    @objc func runTapped() {
        trades = bot.run()
        tableView.isHidden = false
        emptyLabel.isHidden = true
        tableView.reloadData()
        chartVC.loadCandles()
    }
    
    @objc func chartTapped() {
        navigationController?.pushViewController(chartVC, animated: true)
    }
}

// MARK: - CurrencyViewControllerDelegate

extension ViewController: CurrencyViewControllerDelegate {

    func didUpdateCurrencyPair(from: String, to: String) {
        guard from != fromCurrency || to != toCurrency else { return }
        fromCurrency = from
        toCurrency = to
        updatePairButton()
        resetTradingState()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trades.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TradeCell.reuseId, for: indexPath) as? TradeCell else {
            return UITableViewCell()
        }
        cell.configure(with: trades[indexPath.row])
        return cell
    }
}
