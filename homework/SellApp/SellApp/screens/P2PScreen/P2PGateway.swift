import Foundation

class P2PGateway {

    private let networkService = NetworkService.shared

    func fetchRates(
        for currency: String,
        completion: @escaping (Result<[P2PExchangeRateDTO], NetworkError>) -> Void
    ) {
        networkService.fetchRates(for: currency) { result in
            switch result {
            case .success(let rates):
                let dtos = rates.map {
                    P2PExchangeRateDTO(
                        fromCurrency: $0.fromCurrency,
                        toCurrency: $0.toCurrency,
                        rate: $0.rate
                    )
                }
                completion(.success(dtos))
            case .failure(let error):
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
        networkService.executeExchange(from: from, to: to, amount: amount, completion: completion)
    }
}
