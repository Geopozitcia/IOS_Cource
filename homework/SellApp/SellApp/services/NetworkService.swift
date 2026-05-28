import Foundation
import Combine

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
    }

    // switch between old method and combine
    var isNetworkWithCombine: Bool = false

    static let shared = NetworkService()
    private var cancellables = Set<AnyCancellable>()
    private init() {}

    // MARK: - Public API

    func fetchRates(
        for currency: String,
        completion: @escaping (Result<[ExchangeRate], NetworkError>) -> Void
    ) {
        if isNetworkWithCombine {
            fetchRatesWithCombine(for: currency, completion: completion)
        } else {
            fetchRatesClassic(for: currency, completion: completion)
        }
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

// MARK: - Classic

private extension NetworkService {

    func fetchRatesClassic(
        for currency: String,
        completion: @escaping (Result<[ExchangeRate], NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.baseURL)/\(currency)") else {
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

            let result = rates.map {
                ExchangeRate(fromCurrency: currency, toCurrency: $0.key, rate: $0.value)
            }

            DispatchQueue.main.async { completion(.success(result)) }
        }.resume()
    }
}

// MARK: - Combine

private extension NetworkService {

    func fetchRatesWithCombine(
        for currency: String,
        completion: @escaping (Result<[ExchangeRate], NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.baseURL)/\(currency)") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> [ExchangeRate] in
                guard
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let rates = json["rates"] as? [String: Double]
                else {
                    throw NetworkError.decodingFailed
                }
                return rates.map {
                    ExchangeRate(fromCurrency: currency, toCurrency: $0.key, rate: $0.value)
                }
            }
            .mapError { _ in NetworkError.noData }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { rates in
                    completion(.success(rates))
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Exchange simulation

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
                    completion(.success(amount * rate))
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
            completion(.failure(.exchangeFailed("Connection refused")))
            return
        }

        URLSession.shared.dataTask(with: url) { _, _, error in
            DispatchQueue.main.async {
                completion(.failure(.exchangeFailed(error?.localizedDescription ?? "Connection refused")))
            }
        }.resume()
    }
}
