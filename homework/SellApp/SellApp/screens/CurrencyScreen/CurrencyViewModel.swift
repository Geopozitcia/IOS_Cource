import Foundation

final class CurrencyViewModel {

    private enum Constants {
        static let timerInterval: TimeInterval = 1.0
        static let refreshInterval: Int = 5
    }

    var onUpdate: (() -> Void)?
    var onCurrencyPairChanged: ((String, String) -> Void)?

    private let service = CurrencyService.shared

    private(set) var fromCurrency: String = "USD"
    private(set) var toCurrency: String = "BTC"
    private(set) var selectedSlot: Int = 0
    private(set) var secondsUntilRefresh: Int = Constants.refreshInterval
    private(set) var selectedFilter: CurrencyType = .all
    private(set) var inputAmount: Double = 0.0
    private(set) var showFavoritesOnly: Bool = false

    private var timer: Timer?

    var currencies: [String] {
        let filtered = service.currencies(for: selectedFilter)
        if showFavoritesOnly {
            return filtered.filter { service.isFavorite($0) }
        }
        return filtered
    }

    var currentRate: Double {
        return service.rate(from: fromCurrency, to: toCurrency)
    }

    var rateText: String {
        return String(format: "%.6f", currentRate)
    }

    var convertedAmount: String {
        let result = inputAmount * currentRate
        return String(format: "%.6f", result)
    }

    var hasCurrencies: Bool {
        return !currencies.isEmpty
    }

    func setInitialPair(from: String, to: String) {
        fromCurrency = from
        toCurrency = to
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true) { _ in
            self.timerTick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func selectSlot(_ slot: Int) {
        selectedSlot = slot
        onUpdate?()
    }

    func selectCurrency(_ currency: String) {
        if selectedSlot == 0 {
            guard currency != toCurrency else { return }
            fromCurrency = currency
        } else {
            guard currency != fromCurrency else { return }
            toCurrency = currency
        }
        onCurrencyPairChanged?(fromCurrency, toCurrency)
        onUpdate?()
    }

    func isDisabled(_ currency: String) -> Bool {
        return selectedSlot == 0 ? currency == toCurrency : currency == fromCurrency
    }

    func selectFilter(_ filter: CurrencyType) {
        selectedFilter = filter
        onUpdate?()
    }

    func updateInputAmount(_ text: String) {
        inputAmount = Double(text) ?? 0.0
        onUpdate?()
    }

    func toggleFavorite(_ currency: String) {
        service.toggleFavorite(currency)
        onUpdate?()
    }

    func isFavorite(_ currency: String) -> Bool {
        return service.isFavorite(currency)
    }

    func setFavoritesFilter(_ isOn: Bool) {
        showFavoritesOnly = isOn
        onUpdate?()
    }
}

private extension CurrencyViewModel {

    func timerTick() {
        secondsUntilRefresh -= 1

        if secondsUntilRefresh == 0 {
            service.refreshRates()
            secondsUntilRefresh = Constants.refreshInterval
        }

        onUpdate?()
    }
}
