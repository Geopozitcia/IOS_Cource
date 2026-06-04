import Foundation
@testable import SellApp

final class MockP2PGateway: P2PGateway {

    var fetchRatesResult: Result<[P2PExchangeRateDTO], NetworkError> = .success([])
    var executeExchangeResult: Result<Double, NetworkError> = .success(0.0)

    var fetchRatesCalled = false
    var executeExchangeCalled = false
    var lastFetchedCurrency: String?

    override func fetchRates(
        for currency: String,
        completion: @escaping (Result<[P2PExchangeRateDTO], NetworkError>) -> Void
    ) {
        fetchRatesCalled = true
        lastFetchedCurrency = currency
        completion(fetchRatesResult)
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
