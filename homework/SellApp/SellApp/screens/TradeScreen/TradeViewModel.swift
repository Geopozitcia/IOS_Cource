import Foundation

final class TradeViewModel {

    weak var coordinator: TradeCoordinator?

    private let wallet: Wallet
    private var botManager: BotManager?

    private(set) var dayResults: [DayResult] = []
    private(set) var fromCurrency: String = "USD"
    private(set) var toCurrency: String = "BTC"
    private(set) var isLoading: Bool = false

    var onUpdate: (() -> Void)?

    var pairTitle: String {
        return "\(fromCurrency)  →  \(toCurrency)"
    }

    init(wallet: Wallet) {
        self.wallet = wallet
    }

    func runBots() {
        isLoading = true
        onUpdate?()

        let bots = [
            TradingBot(name: "BotAlpha", fromCurrency: fromCurrency, toCurrency: toCurrency),
            TradingBot(name: "BotBeta", fromCurrency: fromCurrency, toCurrency: toCurrency),
            TradingBot(name: "BotGamma", fromCurrency: fromCurrency, toCurrency: toCurrency)
        ]

        let manager = BotManager(bots: bots, wallet: wallet)
        botManager = manager

        manager.runAll { [weak self] results in
            guard let self = self else { return }
            self.isLoading = false
            self.dayResults = results
            self.onUpdate?()
            self.coordinator?.loadChart()
        }
    }

    func reset() {
        dayResults = []
        onUpdate?()
        coordinator?.resetChart()
    }

    func shuffle() {
        let currencies = CurrencyService.shared.currencies
        guard currencies.count >= 2 else { return }
        var from = currencies.randomElement()!
        var to = currencies.randomElement()!
        while to == from {
            to = currencies.randomElement()!
        }
        fromCurrency = from
        toCurrency = to
        reset()
    }

    func updatePair(from: String, to: String) {
        guard from != fromCurrency || to != toCurrency else { return }
        fromCurrency = from
        toCurrency = to
        reset()
    }

    func openChart() {
        coordinator?.showChart()
    }

    func openWallet() {
        coordinator?.showWallet()
    }

    func openCurrencyPicker(delegate: CurrencyViewControllerDelegate) {
        coordinator?.showCurrencyPicker(
            from: fromCurrency,
            to: toCurrency,
            delegate: delegate
        )
    }
    
    func openHeatmap() {
        coordinator?.showHeatmap()
    }
}
