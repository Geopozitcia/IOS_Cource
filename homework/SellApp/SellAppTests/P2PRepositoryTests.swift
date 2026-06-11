import XCTest
@testable import SellApp

final class P2PRepositoryTests: XCTestCase {

    private var sut: P2PRepository!
    private var mockGateway: MockP2PGateway!

    override func setUp() {
        super.setUp()
        mockGateway = MockP2PGateway()
        sut = P2PRepository(gateway: mockGateway)
    }

    override func tearDown() {
        sut = nil
        mockGateway = nil
        super.tearDown()
    }

    func test_fetchOffers_callsGateway() {
        sut.fetchOffers(from: "USD", to: "EUR") { _ in }
        XCTAssertTrue(mockGateway.fetchRatesCalled)
    }

    func test_fetchOffers_passesCorrectCurrency() {
        sut.fetchOffers(from: "USD", to: "EUR") { _ in }
        XCTAssertEqual(mockGateway.lastFetchedCurrency, "USD")
    }

    func test_fetchOffers_returnsOffers_whenRateFound() {
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "EUR", rate: 0.92)
        mockGateway.fetchRatesResult = .success([dto])

        var receivedOffers: [P2POffer] = []
        sut.fetchOffers(from: "USD", to: "EUR") { result in
            if case .success(let offers) = result {
                receivedOffers = offers
            }
        }
        XCTAssertFalse(receivedOffers.isEmpty)
    }

    func test_fetchOffers_returnsEmpty_whenNoMatchingRate() {
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "GBP", rate: 0.79)
        mockGateway.fetchRatesResult = .success([dto])

        var receivedOffers: [P2POffer] = []
        sut.fetchOffers(from: "USD", to: "EUR") { result in
            if case .success(let offers) = result {
                receivedOffers = offers
            }
        }
        XCTAssertTrue(receivedOffers.isEmpty)
    }

    func test_fetchOffers_returnsError_whenGatewayFails() {
        mockGateway.fetchRatesResult = .failure(.noData)

        var receivedError: NetworkError?
        sut.fetchOffers(from: "USD", to: "EUR") { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        XCTAssertNotNil(receivedError)
    }

    func test_executeExchange_callsGateway() {
        sut.executeExchange(from: "USD", to: "EUR", amount: 100) { _ in }
        XCTAssertTrue(mockGateway.executeExchangeCalled)
    }

    func test_executeExchange_returnsSuccess() {
        mockGateway.executeExchangeResult = .success(92.0)

        var receivedAmount: Double?
        sut.executeExchange(from: "USD", to: "EUR", amount: 100) { result in
            if case .success(let amount) = result {
                receivedAmount = amount
            }
        }
        XCTAssertEqual(receivedAmount, 92.0)
    }
}
