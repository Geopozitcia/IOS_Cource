import Foundation

final class P2PViewModel {

    private enum Constants {
        static let sellerNames = [
            "CryptoKing", "FastTrader", "P2PMaster",
            "CoinSwap", "SafeExchange", "TrustPeer",
            "QuickDeal", "AlphaTrader", "BitBroker"
        ]
        static let discountRange: ClosedRange<Double> = 0.95...0.99
    }

    weak var coordinator: P2PCoordinator?

    private let wallet: Wallet

    private(set) var fromCurrency: String = "USD"
    private(set) var toCurrency: String = "EUR"
    private(set) var offers: [P2POffer] = []
    private(set) var isLoading: Bool = false

    var onUpdate: (() -> Void)?
    var onError: (() -> Void)?

    var fromBalance: String {
        let balance = wallet.balance(for: fromCurrency)
        return "Balance: \(String(format: "%.2f", balance)) \(fromCurrency)"
    }

    var toBalance: String {
        let balance = wallet.balance(for: toCurrency)
        return "Balance: \(String(format: "%.2f", balance)) \(toCurrency)"
    }

    init(wallet: Wallet) {
        self.wallet = wallet
    }

    func loadOffers() {
        isLoading = true
        onUpdate?()

        NetworkService.shared.fetchRates(for: fromCurrency) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let rates):
                if let rate = rates.first(where: { $0.toCurrency == self.toCurrency })?.rate {
                    self.offers = self.generateOffers(from: rate)
                } else {
                    self.offers = []
                }
            case .failure:
                self.offers = []
            }

            self.onUpdate?()
        }
    }

    func updatePair(from: String, to: String) {
        fromCurrency = from
        toCurrency = to
        loadOffers()
    }

    func selectOffer(_ offer: P2POffer) {
        coordinator?.showExchangeAlert(
            offer: offer,
            fromCurrency: fromCurrency
        ) { [weak self] amount in
            self?.executeExchange(amount: amount, offer: offer)
        }
    }

    func openSellerInfo(_ offer: P2POffer) {
        coordinator?.showSellerInfo(offer)
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
}

private extension P2PViewModel {

    func generateOffers(from baseRate: Double) -> [P2POffer] {
        return Constants.sellerNames.map { name in
            let discount = Double.random(in: Constants.discountRange)
            let rate = baseRate * discount
            let reserve = Double.random(in: 100...10000)
            return P2POffer(sellerName: name, rate: rate, reserve: reserve)
        }.sorted { $0.rate > $1.rate }
    }

    func executeExchange(amount: Double, offer: P2POffer) {
        NetworkService.shared.executeExchange(
            from: fromCurrency,
            to: toCurrency,
            amount: amount
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let received):
                self.wallet.deduct(amount: amount, currency: self.fromCurrency)
                self.wallet.deposit(amount: received, currency: self.toCurrency)
                self.onUpdate?()
                self.coordinator?.showResult(
                    success: true,
                    message: "You received \(String(format: "%.4f", received)) \(self.toCurrency)"
                )
            case .failure(let error):
                self.coordinator?.showResult(success: false, message: error.description)
            }
        }
    }
}
