import XCTest
@testable import SellApp

final class P2PUseCaseTests: XCTestCase {

    private var mockRepository: MockP2PRepository!
    private var loadOffersUseCase: LoadOffersUseCase!
    private var executeExchangeUseCase: ExecuteExchangeUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockP2PRepository()
        loadOffersUseCase = LoadOffersUseCase(repository: mockRepository)
        executeExchangeUseCase = ExecuteExchangeUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        loadOffersUseCase = nil
        executeExchangeUseCase = nil
        super.tearDown()
    }

    // MARK: - LoadOffersUseCase

    func test_loadOffers_callsRepository() {
        loadOffersUseCase.execute(from: "USD", to: "EUR") { _ in }
        XCTAssertTrue(mockRepository.fetchOffersCalled)
    }

    func test_loadOffers_passesCorrectCurrencies() {
        loadOffersUseCase.execute(from: "USD", to: "EUR") { _ in }
        XCTAssertEqual(mockRepository.lastFromCurrency, "USD")
        XCTAssertEqual(mockRepository.lastToCurrency, "EUR")
    }

    func test_loadOffers_returnsOffers_onSuccess() {
        let offers = [P2POffer(sellerName: "TestSeller", rate: 0.9, reserve: 1000)]
        mockRepository.fetchOffersResult = .success(offers)

        var receivedOffers: [P2POffer] = []
        loadOffersUseCase.execute(from: "USD", to: "EUR") { result in
            if case .success(let offers) = result {
                receivedOffers = offers
            }
        }
        XCTAssertEqual(receivedOffers.count, 1)
        XCTAssertEqual(receivedOffers.first?.sellerName, "TestSeller")
    }

    func test_loadOffers_returnsError_onFailure() {
        mockRepository.fetchOffersResult = .failure(.noData)

        var receivedError: NetworkError?
        loadOffersUseCase.execute(from: "USD", to: "EUR") { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        XCTAssertNotNil(receivedError)
    }

    // MARK: - ExecuteExchangeUseCase

    func test_executeExchange_callsRepository() {
        executeExchangeUseCase.execute(from: "USD", to: "EUR", amount: 100) { _ in }
        XCTAssertTrue(mockRepository.executeExchangeCalled)
    }

    func test_executeExchange_returnsCorrectAmount_onSuccess() {
        mockRepository.executeExchangeResult = .success(92.0)

        var receivedAmount: Double?
        executeExchangeUseCase.execute(from: "USD", to: "EUR", amount: 100) { result in
            if case .success(let amount) = result {
                receivedAmount = amount
            }
        }
        XCTAssertEqual(receivedAmount, 92.0)
    }

    func test_executeExchange_returnsError_onFailure() {
        mockRepository.executeExchangeResult = .failure(.exchangeFailed("test error"))

        var receivedError: NetworkError?
        executeExchangeUseCase.execute(from: "USD", to: "EUR", amount: 100) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        XCTAssertNotNil(receivedError)
    }
}
