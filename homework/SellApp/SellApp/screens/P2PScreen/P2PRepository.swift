import Foundation

class P2PRepository {

    private let gateway: P2PGateway
    private let mapper = P2PDataMapper()

    init(gateway: P2PGateway = P2PGateway()) {
        self.gateway = gateway
    }

    func fetchOffers(
        from currency: String,
        to targetCurrency: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        gateway.fetchRates(for: currency) { result in
            switch result {
            case .success(let dtos):
                guard let dto = dtos.first(where: { $0.toCurrency == targetCurrency }) else {
                    completion(.success([]))
                    return
                }
                let offers = self.mapper.mapToOffers(from: dto)
                completion(.success(offers))
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
        gateway.executeExchange(from: from, to: to, amount: amount, completion: completion)
    }
}
