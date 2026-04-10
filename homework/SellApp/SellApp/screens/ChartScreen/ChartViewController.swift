import UIKit

final class ChartViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let candleWidth: CGFloat = 50
        static let candleHeight: CGFloat = 160
        static let infoPanelHeight: CGFloat = 100
        static let recommendationHeight: CGFloat = 60
    }

    private var candles: [CandleModel] = []

    private let scrollView = UIScrollView()
    private let candleStackView = UIStackView()

    private let infoPanel = UIView()
    private let openLabel = UILabel()
    private let closeLabel = UILabel()
    private let highLabel = UILabel()
    private let lowLabel = UILabel()
    private let infoPlaceholder = UILabel()

    private let recommendationView = UIView()
    private let recommendationLabel = UILabel()
    private let recommendationPlaceholder = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chart"
        setupBackground()
        setupSubviews()
        setupConstraints()
    }
    
    func loadCandles() {
        candles = CandleModel.generateList(count: 30)
        candleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        populateCandles()
    }

    func resetCandles() {
        candles = []
        candleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        infoPlaceholder.isHidden = false
        infoPanel.viewWithTag(100)?.isHidden = true
        recommendationLabel.isHidden = true
        recommendationPlaceholder.isHidden = false
    }
    
}

// MARK: - Setup

private extension ChartViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
    }

    func setupSubviews() {
        setupScrollView()
        setupInfoPanel()
        setupRecommendationView()

        view.addSubview(infoPanel)
        view.addSubview(recommendationView)
        view.addSubview(scrollView)
    }

    func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        candleStackView.axis = .horizontal
        candleStackView.spacing = 8
        candleStackView.alignment = .center
        candleStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(candleStackView)
    }

    func setupInfoPanel() {
        infoPanel.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        infoPanel.layer.cornerRadius = 10
        infoPanel.translatesAutoresizingMaskIntoConstraints = false

        infoPlaceholder.text = "Tap a candle to see details"
        infoPlaceholder.textColor = .systemGray
        infoPlaceholder.font = .systemFont(ofSize: 14)
        infoPlaceholder.textAlignment = .center
        infoPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        setupInfoLabel(openLabel)
        setupInfoLabel(closeLabel)
        setupInfoLabel(highLabel)
        setupInfoLabel(lowLabel)

        let infoStack = UIStackView(arrangedSubviews: [openLabel, closeLabel, highLabel, lowLabel])
        infoStack.axis = .horizontal
        infoStack.distribution = .fillEqually
        infoStack.spacing = 8
        infoStack.isHidden = true
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.tag = 100

        infoPanel.addSubview(infoPlaceholder)
        infoPanel.addSubview(infoStack)

        NSLayoutConstraint.activate([
            infoPlaceholder.centerXAnchor.constraint(equalTo: infoPanel.centerXAnchor),
            infoPlaceholder.centerYAnchor.constraint(equalTo: infoPanel.centerYAnchor),

            infoStack.topAnchor.constraint(equalTo: infoPanel.topAnchor, constant: Constants.padding),
            infoStack.bottomAnchor.constraint(equalTo: infoPanel.bottomAnchor, constant: -Constants.padding),
            infoStack.leadingAnchor.constraint(equalTo: infoPanel.leadingAnchor, constant: Constants.padding),
            infoStack.trailingAnchor.constraint(equalTo: infoPanel.trailingAnchor, constant: -Constants.padding)
        ])
    }

    func setupInfoLabel(_ label: UILabel) {
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupRecommendationView() {
        recommendationView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        recommendationView.layer.cornerRadius = 10
        recommendationView.translatesAutoresizingMaskIntoConstraints = false

        recommendationPlaceholder.text = "Long press a candle for recommendation"
        recommendationPlaceholder.textColor = .systemGray
        recommendationPlaceholder.font = .systemFont(ofSize: 14)
        recommendationPlaceholder.textAlignment = .center
        recommendationPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        recommendationLabel.textColor = .white
        recommendationLabel.font = .systemFont(ofSize: 18, weight: .bold)
        recommendationLabel.textAlignment = .center
        recommendationLabel.isHidden = true
        recommendationLabel.translatesAutoresizingMaskIntoConstraints = false

        recommendationView.addSubview(recommendationPlaceholder)
        recommendationView.addSubview(recommendationLabel)

        NSLayoutConstraint.activate([
            recommendationPlaceholder.centerXAnchor.constraint(equalTo: recommendationView.centerXAnchor),
            recommendationPlaceholder.centerYAnchor.constraint(equalTo: recommendationView.centerYAnchor),

            recommendationLabel.centerXAnchor.constraint(equalTo: recommendationView.centerXAnchor),
            recommendationLabel.centerYAnchor.constraint(equalTo: recommendationView.centerYAnchor)
        ])
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            infoPanel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            infoPanel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            infoPanel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            infoPanel.heightAnchor.constraint(equalToConstant: Constants.infoPanelHeight),

            recommendationView.topAnchor.constraint(equalTo: infoPanel.bottomAnchor, constant: Constants.padding),
            recommendationView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            recommendationView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            recommendationView.heightAnchor.constraint(equalToConstant: Constants.recommendationHeight),

            scrollView.topAnchor.constraint(equalTo: recommendationView.bottomAnchor, constant: Constants.padding),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            candleStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            candleStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            candleStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            candleStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            candleStackView.heightAnchor.constraint(equalToConstant: Constants.candleHeight)
        ])
    }

    func populateCandles() {
        candles.forEach { model in
            let candle = CandleView(frame: CGRect(x: 0, y: 0, width: Constants.candleWidth, height: Constants.candleHeight))
            candle.configure(with: model)

            candle.onTap = { [weak self] tappedModel in
                self?.showCandleInfo(tappedModel)
            }
            candle.onLongPress = { [weak self] tappedModel in
                self?.showRecommendation(for: tappedModel)
            }

            candleStackView.addArrangedSubview(candle)

            NSLayoutConstraint.activate([
                candle.widthAnchor.constraint(equalToConstant: Constants.candleWidth),
                candle.heightAnchor.constraint(equalToConstant: Constants.candleHeight)
            ])
        }
    }

    func showCandleInfo(_ model: CandleModel) {
        openLabel.text = "Open\n\(String(format: "%.1f", model.open))"
        closeLabel.text = "Close\n\(String(format: "%.1f", model.close))"
        highLabel.text = "High\n\(String(format: "%.1f", model.high))"
        lowLabel.text = "Low\n\(String(format: "%.1f", model.low))"

        infoPlaceholder.isHidden = true
        if let infoStack = infoPanel.viewWithTag(100) {
            infoStack.isHidden = false
        }
    }

    func showRecommendation(for model: CandleModel) {
        let options = ["Buy", "Sell", "Wait"]
        let result = options.randomElement() ?? "Wait"

        switch result {
        case "Buy":
            recommendationLabel.textColor = .systemGreen
        case "Sell":
            recommendationLabel.textColor = .systemRed
        default:
            recommendationLabel.textColor = .systemYellow
        }

        recommendationLabel.text = result
        recommendationPlaceholder.isHidden = true
        recommendationLabel.isHidden = false
    }
}
