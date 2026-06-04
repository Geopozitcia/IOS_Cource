import Foundation
import OSLog

class P2PGateway {

    private let networkService = NetworkService.shared

    func fetchRates(
        for currency: String,
        completion: @escaping (Result<[P2PExchangeRateDTO], NetworkError>) -> Void
    ) {
        AppLogger.network.info("Fetching rates for currency: \(currency)")

        networkService.fetchRates(for: currency) { result in
            switch result {
            case .success(let rates):
                AppLogger.network.info("Rates fetched successfully for \(currency): \(rates.count) rates")
                let dtos = rates.map {
                    P2PExchangeRateDTO(
                        fromCurrency: $0.fromCurrency,
                        toCurrency: $0.toCurrency,
                        rate: $0.rate
                    )
                }
                completion(.success(dtos))
            case .failure(let error):
                AppLogger.network.error("Failed to fetch rates for \(currency): \(error.description)")
                completion(.failure(error))
            }
        }
    }

    func executeExchange(
        from: String,
        to: String,
        amount: Double,
        completion: @escaping (Result<Double, NetworkError>) -> Void
    ) {
        AppLogger.network.info("Executing exchange: \(amount) \(from) → \(to)")

        networkService.executeExchange(from: from, to: to, amount: amount) { result in
            switch result {
            case .success(let received):
                AppLogger.network.info("Exchange successful: received \(received) \(to)")
                completion(.success(received))
            case .failure(let error):
                AppLogger.network.error("Exchange failed: \(error.description)")
                completion(.failure(error))
            }
        }
    }
}
