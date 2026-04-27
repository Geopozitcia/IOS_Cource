import Foundation

struct ExchangeRate {
    let fromCurrency: String
    let toCurrency: String
    let rate: Double
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case exchangeFailed(String)

    var description: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingFailed: return "Failed to decode response"
        case .exchangeFailed(let reason): return "Exchange failed: \(reason)"
        }
    }
}

final class NetworkService {

    private enum Constants {
        static let baseURL = "https://open.er-api.com/v6/latest"
        static let fakeExchangeURL = "https://fake-exchange-api.nonexistent/execute"
        static let successProbability = 0.5
    }

    static let shared = NetworkService()
    private init() {}

    func fetchRates(for currency: String, completion: @escaping (Result<[ExchangeRate], NetworkError>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/\(currency)") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let _ = error {
                completion(.failure(.noData))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let rates = json["rates"] as? [String: Double]
            else {
                completion(.failure(.decodingFailed))
                return
            }

            let exchangeRates = rates.map {
                ExchangeRate(fromCurrency: currency, toCurrency: $0.key, rate: $0.value)
            }

            DispatchQueue.main.async {
                completion(.success(exchangeRates))
            }
        }.resume()
    }

    func executeExchange(
        from: String,
        to: String,
        amount: Double,
        completion: @escaping (Result<Double, NetworkError>) -> Void
    ) {
        if Bool.random() {
            simulateSuccess(from: from, to: to, amount: amount, completion: completion)
        } else {
            simulateFailure(completion: completion)
        }
    }
}

private extension NetworkService {

    func simulateSuccess(
        from: String,
        to: String,
        amount: Double,
        completion: @escaping (Result<Double, NetworkError>) -> Void
    ) {
        fetchRates(for: from) { result in
            switch result {
            case .success(let rates):
                if let rate = rates.first(where: { $0.toCurrency == to })?.rate {
                    let received = amount * rate
                    completion(.success(received))
                } else {
                    completion(.failure(.exchangeFailed("Rate not found")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func simulateFailure(completion: @escaping (Result<Double, NetworkError>) -> Void) {
        guard let url = URL(string: Constants.fakeExchangeURL) else {
            completion(.failure(.exchangeFailed("Connection refused by server")))
            return
        }

        URLSession.shared.dataTask(with: url) { _, _, error in
            DispatchQueue.main.async {
                completion(.failure(.exchangeFailed(error?.localizedDescription ?? "Connection refused")))
            }
        }.resume()
    }
}
