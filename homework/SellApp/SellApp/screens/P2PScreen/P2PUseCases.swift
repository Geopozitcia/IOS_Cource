import Foundation

final class LoadOffersUseCase {

    private let repository: P2PRepository

    init(repository: P2PRepository = P2PRepository()) {
        self.repository = repository
    }

    func execute(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        repository.fetchOffers(from: from, to: to, completion: completion)
    }
}

final class ExecuteExchangeUseCase {

    private let repository: P2PRepository

    init(repository: P2PRepository = P2PRepository()) {
        self.repository = repository
    }

    func execute(
        from: String,
        to: String,
        amount: Double,
        completion: @escaping (Result<Double, NetworkError>) -> Void
    ) {
        repository.executeExchange(from: from, to: to, amount: amount, completion: completion)
    }
}
