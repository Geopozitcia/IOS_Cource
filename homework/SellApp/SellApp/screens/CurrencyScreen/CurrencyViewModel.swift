import Foundation

final class CurrencyViewModel {

    private enum Constants {
        static let timerInterval: TimeInterval = 1.0
        static let refreshInterval: Int = 5
    }

    var onUpdate: (() -> Void)?

    private let service = CurrencyService.shared

    private(set) var fromCurrency: String = "USD"
    private(set) var toCurrency: String = "BTC"
    private(set) var selectedSlot: Int = 0
    private(set) var secondsUntilRefresh: Int = Constants.refreshInterval
    private(set) var selectedFilter: CurrencyType = .all // save currency filter
    private(set) var inputAmount: Double = 0.0

    private var timer: Timer?

    var currencies: [String] {
        return service.currencies(for: selectedFilter)
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

    func start() {
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
        onUpdate?()
    }

    func isDisabled(_ currency: String) -> Bool {
        return selectedSlot == 0 ? currency == toCurrency : currency == fromCurrency
    }

    func selectFilter(_ filter: CurrencyType) { // all, crypro or just normal (not scam) money  
        selectedFilter = filter
        onUpdate?()
    }

    func updateInputAmount(_ text: String) {
        inputAmount = Double(text) ?? 0.0
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
