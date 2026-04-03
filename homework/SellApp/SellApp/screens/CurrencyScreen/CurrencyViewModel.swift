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

    private var timer: Timer?

    var currencies: [String] {
        return service.currencies
    }

    var currentRate: Double {
        return service.rate(from: fromCurrency, to: toCurrency)
    }

    var rateText: String {
        return String(format: "%.6f", currentRate)
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
