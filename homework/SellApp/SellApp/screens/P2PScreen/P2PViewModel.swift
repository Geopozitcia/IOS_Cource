import Foundation
import OSLog

enum P2PScreenState { // enum replace isLoading: Bool
    case idle
    case loading
    case loaded([P2POffer])
    case error(String)
}

final class P2PViewModel {

    private enum Constants {
        static let defaultFromCurrency = "USD"
        static let defaultToCurrency = "EUR"
    }

    weak var coordinator: P2PCoordinator?

    private let wallet: Wallet
    private let loadOffersUseCase: LoadOffersUseCase
    private let executeExchangeUseCase: ExecuteExchangeUseCase

    private(set) var state: P2PScreenState = .idle
    private(set) var fromCurrency: String = Constants.defaultFromCurrency
    private(set) var toCurrency: String = Constants.defaultToCurrency

    var onUpdate: (() -> Void)?

    var offers: [P2POffer] { // comuting var
        if case .loaded(let offers) = state { return offers }
        return []
    }

    var isLoading: Bool { // computing var
        if case .loading = state { return true }
        return false
    }

    var fromBalance: String {
        let balance = wallet.balance(for: fromCurrency)
        return "Balance: \(String(format: "%.2f", balance)) \(fromCurrency)"
    }

    var toBalance: String {
        let balance = wallet.balance(for: toCurrency)
        return "Balance: \(String(format: "%.2f", balance)) \(toCurrency)"
    }

    init(
        wallet: Wallet,
        loadOffersUseCase: LoadOffersUseCase = LoadOffersUseCase(),
        executeExchangeUseCase: ExecuteExchangeUseCase = ExecuteExchangeUseCase()
    ) {
        self.wallet = wallet
        self.loadOffersUseCase = loadOffersUseCase
        self.executeExchangeUseCase = executeExchangeUseCase
    }

    func loadOffers() {
        AppLogger.p2p.info("Loading offers: \(self.fromCurrency) → \(self.toCurrency)")
        state = .loading
        onUpdate?()

        loadOffersUseCase.execute(from: fromCurrency, to: toCurrency) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let offers):
                if offers.isEmpty {
                    AppLogger.p2p.warning("No offers found for \(self.fromCurrency) → \(self.toCurrency)")
                    self.state = .error("No offers available")
                } else {
                    AppLogger.p2p.info("Loaded \(offers.count) offers for \(self.fromCurrency) → \(self.toCurrency)")
                    self.state = .loaded(offers)
                }
            case .failure(let error):
                AppLogger.p2p.error("Failed to load offers: \(error.description)")
                self.state = .error(error.description)
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

    func executeExchange(amount: Double, offer: P2POffer) {
        AppLogger.p2p.info("Executing exchange with \(offer.sellerName): \(amount) \(self.fromCurrency) → \(self.toCurrency)")
        executeExchangeUseCase.execute(
            from: fromCurrency,
            to: toCurrency,
            amount: amount
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let received):
                AppLogger.p2p.info("Exchange completed: received \(received) \(self.toCurrency)")
                self.wallet.deduct(amount: amount, currency: self.fromCurrency)
                self.wallet.deposit(amount: received, currency: self.toCurrency)
                self.onUpdate?()
                self.coordinator?.showResult(
                    success: true,
                    message: "You received \(String(format: "%.4f", received)) \(self.toCurrency)"
                )
            case .failure(let error):
                AppLogger.p2p.error("Exchange failed: \(error.description)")
                self.coordinator?.showResult(success: false, message: error.description)
            }
        }
    }
}
