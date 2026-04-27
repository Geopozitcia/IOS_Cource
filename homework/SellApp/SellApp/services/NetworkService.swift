import Foundation

struct ExchangeRate {
    let fromCurrency: String
    let toCurrency: String
    let rate: Double
}

struct P2POffer {
    let sellerName: String
    let rate: Double
    let reserve: Double
    let fromCurrency: String
    let toCurrency: String
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case transactionFailed(String)
}

enum ExchangeResult {
    case success(newBalance: Double)
    case failure(NetworkError)
}

final class NetworkService {

    private enum Constants {
        static let baseURL = "https://open.er-api.com/v6/latest/"
        static let minDiscount: Double = 0.01
        static let maxDiscount: Double = 0.05
        static let minReserve: Double = 100.0
        static let maxReserve: Double = 50000.0
        static let offersCount: Int = 8
        static let fakeTransactionURL = "https://fake-p2p-exchange.invalid/transaction"
        static let sellerNames = [
            "CryptoKing", "BitMaster", "FastExchange",
            "SecureTrader", "P2PGuru", "QuickSwap",
            "TrustDealer", "EliteExchange", "SmartTrader",
            "ProSwapper", "SafeHands", "TopRater"
        ]
    }

    static let shared = NetworkService()
    private(set) var availableCurrencies: [String] = []

    private init() {}

    func fetchRates(for currency: String, completion: @escaping (Result<[ExchangeRate], NetworkError>) -> Void) {
        guard let url = URL(string: Constants.baseURL + currency) else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let rates = json["rates"] as? [String: Double]
            else {
                DispatchQueue.main.async { completion(.failure(.decodingFailed)) }
                return
            }

            let exchangeRates = rates.map { ExchangeRate(fromCurrency: currency, toCurrency: $0.key, rate: $1) }
            self.availableCurrencies = Array(Set([currency] + rates.keys)).sorted()

            DispatchQueue.main.async { completion(.success(exchangeRates)) }
        }.resume()
    }

    func generateOffers(for rate: ExchangeRate) -> [P2POffer] {
        let names = Constants.sellerNames.shuffled().prefix(Constants.offersCount)
        return names.map { name in
            let discount = Double.random(in: Constants.minDiscount...Constants.maxDiscount)
            let offerRate = rate.rate * (1 - discount)
            let reserve = Double.random(in: Constants.minReserve...Constants.maxReserve)
            return P2POffer(
                sellerName: name,
                rate: offerRate,
                reserve: reserve,
                fromCurrency: rate.fromCurrency,
                toCurrency: rate.toCurrency
            )
        }.sorted { $0.rate > $1.rate }
    }

    func performExchange(
        offer: P2POffer,
        amount: Double,
        wallet: Wallet,
        completion: @escaping (ExchangeResult) -> Void
    ) {
        if Bool.random() {
            simulateSuccess(offer: offer, amount: amount, wallet: wallet, completion: completion)
        } else {
            simulateFailure(completion: completion)
        }
    }
}

private extension NetworkService {

    func simulateSuccess(offer: P2POffer, amount: Double, wallet: Wallet, completion: @escaping (ExchangeResult) -> Void) {
        wallet.deduct(amount: amount, currency: offer.fromCurrency)
        let received = amount * offer.rate
        wallet.deposit(amount: received, currency: offer.toCurrency)
        let newBalance = wallet.balance(for: offer.toCurrency)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(newBalance: newBalance))
        }
    }

    func simulateFailure(completion: @escaping (ExchangeResult) -> Void) {
        guard let url = URL(string: Constants.fakeTransactionURL) else {
            DispatchQueue.main.async {
                completion(.failure(.transactionFailed("Transaction declined by server")))
            }
            return
        }

        URLSession.shared.dataTask(with: url) { _, _, _ in
            DispatchQueue.main.async {
                completion(.failure(.transactionFailed("Transaction declined by server")))
            }
        }.resume()
    }
}
