import UIKit

final class ChartViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let candleWidth: CGFloat = 50
        static let candleHeight: CGFloat = 160
        static let infoPanelHeight: CGFloat = 100
        static let recommendationHeight: CGFloat = 60
        static let switcherHeight: CGFloat = 36
        static let lineChartHeight: CGFloat = 200
        static let switcherCornerRadius: CGFloat = 8
        static let switcherFontSize: CGFloat = 14
        static let switcherBorderWidth: CGFloat = 1
    }

    private var candles: [CandleModel] = []

    // switcher
    private let switcherStack = UIStackView()
    private let candleButton = UIButton(type: .system)
    private let lineButton = UIButton(type: .system)

    // candle chart
    private let scrollView = UIScrollView()
    private let candleStackView = UIStackView()

    // line chart
    private let lineChartView = LineChartView()

    // info panel
    private let infoPanel = UIView()
    private let openLabel = UILabel()
    private let closeLabel = UILabel()
    private let highLabel = UILabel()
    private let lowLabel = UILabel()
    private let infoPlaceholder = UILabel()

    // recommendation
    private let recommendationView = UIView()
    private let recommendationLabel = UILabel()
    private let recommendationPlaceholder = UILabel()

    private var showingCandles: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chart"
        setupBackground()
        setupSubviews()
        setupConstraints()
        updateSwitcherUI()
    }

    func loadCandles() {
        candles = CandleModel.generateList(count: 30)
        candleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        populateCandles()
        lineChartView.configure(with: candles.map { $0.close })
    }

    func resetCandles() {
        candles = []
        candleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        lineChartView.configure(with: [])
        resetInfoPanel()
        resetRecommendation()
    }
}

// MARK: - Setup

private extension ChartViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    func setupSubviews() {
        setupSwitcher()
        setupScrollView()
        setupLineChart()
        setupInfoPanel()
        setupRecommendationView()

        view.addSubview(infoPanel)
        view.addSubview(recommendationView)
        view.addSubview(switcherStack)
        view.addSubview(scrollView)
        view.addSubview(lineChartView)
    }

    func setupSwitcher() {
        setupSwitcherButton(candleButton, title: "Candles", action: #selector(candlesTapped))
        setupSwitcherButton(lineButton, title: "Line", action: #selector(lineTapped))

        switcherStack.axis = .horizontal
        switcherStack.distribution = .fillEqually
        switcherStack.spacing = 8
        switcherStack.addArrangedSubview(candleButton)
        switcherStack.addArrangedSubview(lineButton)
        switcherStack.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupSwitcherButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        button.layer.cornerRadius = Constants.switcherCornerRadius
        button.layer.borderWidth = Constants.switcherBorderWidth
        button.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        button.titleLabel?.font = .systemFont(ofSize: Constants.switcherFontSize, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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

    func setupLineChart() {
        lineChartView.isHidden = true
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
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

            switcherStack.topAnchor.constraint(equalTo: recommendationView.bottomAnchor, constant: Constants.padding),
            switcherStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            switcherStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            switcherStack.heightAnchor.constraint(equalToConstant: Constants.switcherHeight),

            scrollView.topAnchor.constraint(equalTo: switcherStack.bottomAnchor, constant: Constants.padding),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            candleStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            candleStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            candleStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            candleStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            candleStackView.heightAnchor.constraint(equalToConstant: Constants.candleHeight),

            lineChartView.topAnchor.constraint(equalTo: switcherStack.bottomAnchor, constant: Constants.padding),
            lineChartView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            lineChartView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            lineChartView.heightAnchor.constraint(equalToConstant: Constants.lineChartHeight)
        ])
    }
}

// MARK: - Candles

private extension ChartViewController {

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
        infoPanel.viewWithTag(100)?.isHidden = false
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

    func resetInfoPanel() {
        infoPlaceholder.isHidden = false
        infoPanel.viewWithTag(100)?.isHidden = true
    }

    func resetRecommendation() {
        recommendationLabel.isHidden = true
        recommendationPlaceholder.isHidden = false
    }
}

// MARK: - Switcher

private extension ChartViewController {

    func updateSwitcherUI() {
        candleButton.backgroundColor = showingCandles
            ? .systemBlue
            : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lineButton.backgroundColor = showingCandles
            ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            : .systemBlue

        scrollView.isHidden = !showingCandles
        lineChartView.isHidden = showingCandles

        // hide unnecessary panels in line mode
        infoPanel.isHidden = !showingCandles
        recommendationView.isHidden = !showingCandles
    }

    @objc func candlesTapped() {
        showingCandles = true
        updateSwitcherUI()
    }

    @objc func lineTapped() {
        showingCandles = false
        updateSwitcherUI()
    }
}
