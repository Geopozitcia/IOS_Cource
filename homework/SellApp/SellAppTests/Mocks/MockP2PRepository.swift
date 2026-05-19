import Foundation
@testable import SellApp

final class MockP2PRepository: P2PRepository {

    var fetchOffersResult: Result<[P2POffer], NetworkError> = .success([])
    var executeExchangeResult: Result<Double, NetworkError> = .success(0.0)

    var fetchOffersCalled = false
    var executeExchangeCalled = false
    var lastFromCurrency: String?
    var lastToCurrency: String?

    override func fetchOffers(
        from currency: String,
        to targetCurrency: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        fetchOffersCalled = true
        lastFromCurrency = currency
        lastToCurrency = targetCurrency
        completion(fetchOffersResult)
    }

    override func executeExchange(
        from: String,
        to: String,
        amount: Double,
        completion: @escaping (Result<Double, NetworkError>) -> Void
    ) {
        executeExchangeCalled = true
        completion(executeExchangeResult)
    }
}
