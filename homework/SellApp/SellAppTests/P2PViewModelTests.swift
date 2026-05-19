import XCTest
@testable import SellApp

final class P2PViewModelTests: XCTestCase {

    private var sut: P2PViewModel!
    private var mockRepository: MockP2PRepository!
    private var wallet: Wallet!

    override func setUp() {
        super.setUp()
        mockRepository = MockP2PRepository()
        wallet = Wallet(currencies: ["USD", "EUR", "BTC"])
        let loadOffersUseCase = LoadOffersUseCase(repository: mockRepository)
        let executeExchangeUseCase = ExecuteExchangeUseCase(repository: mockRepository)
        sut = P2PViewModel(
            wallet: wallet,
            loadOffersUseCase: loadOffersUseCase,
            executeExchangeUseCase: executeExchangeUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        wallet = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_isIdle() {
        if case .idle = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected idle state")
        }
    }

    func test_initialCurrencies_areCorrect() {
        XCTAssertEqual(sut.fromCurrency, "USD")
        XCTAssertEqual(sut.toCurrency, "EUR")
    }

    func test_initialOffers_isEmpty() {
        XCTAssertTrue(sut.offers.isEmpty)
    }

    func test_initialIsLoading_isFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - loadOffers

    func test_loadOffers_setsLoadingState() {
        var states: [P2PScreenState] = []
        sut.onUpdate = {
            states.append(self.sut.state)
        }
        sut.loadOffers()
        XCTAssertTrue(states.first.map {
            if case .loading = $0 { return true }
            return false
        } ?? false)
    }

    func test_loadOffers_setsLoadedState_onSuccess() {
        let offers = [P2POffer(sellerName: "TestSeller", rate: 0.9, reserve: 1000)]
        mockRepository.fetchOffersResult = .success(offers)

        let expectation = expectation(description: "onUpdate called")
        var callCount = 0
        sut.onUpdate = {
            callCount += 1
            if callCount == 2 { expectation.fulfill() }
        }

        sut.loadOffers()
        waitForExpectations(timeout: 1)

        if case .loaded(let receivedOffers) = sut.state {
            XCTAssertEqual(receivedOffers.count, 1)
            XCTAssertEqual(receivedOffers.first?.sellerName, "TestSeller")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func test_loadOffers_setsErrorState_onFailure() {
        mockRepository.fetchOffersResult = .failure(.noData)

        let expectation = expectation(description: "onUpdate called")
        var callCount = 0
        sut.onUpdate = {
            callCount += 1
            if callCount == 2 { expectation.fulfill() }
        }

        sut.loadOffers()
        waitForExpectations(timeout: 1)

        if case .error = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error state")
        }
    }

    func test_loadOffers_setsErrorState_whenOffersEmpty() {
        mockRepository.fetchOffersResult = .success([])

        let expectation = expectation(description: "onUpdate called")
        var callCount = 0
        sut.onUpdate = {
            callCount += 1
            if callCount == 2 { expectation.fulfill() }
        }

        sut.loadOffers()
        waitForExpectations(timeout: 1)

        if case .error = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error state for empty offers")
        }
    }

    // MARK: - updatePair

    func test_updatePair_changesCurrencies() {
        sut.updatePair(from: "BTC", to: "USD")
        XCTAssertEqual(sut.fromCurrency, "BTC")
        XCTAssertEqual(sut.toCurrency, "USD")
    }

    func test_updatePair_triggersLoadOffers() {
        sut.updatePair(from: "BTC", to: "USD")
        XCTAssertTrue(mockRepository.fetchOffersCalled)
    }

    // MARK: - Balance

    func test_fromBalance_showsCorrectFormat() {
        XCTAssertEqual(sut.fromBalance, "Balance: 1000.00 USD")
    }

    func test_toBalance_showsCorrectFormat() {
        XCTAssertEqual(sut.toBalance, "Balance: 1000.00 EUR")
    }

    // MARK: - offers computed property

    func test_offers_returnsEmpty_whenNotLoaded() {
        XCTAssertTrue(sut.offers.isEmpty)
    }

    func test_offers_returnsOffers_whenLoaded() {
        let offers = [P2POffer(sellerName: "TestSeller", rate: 0.9, reserve: 1000)]
        mockRepository.fetchOffersResult = .success(offers)

        let expectation = expectation(description: "loaded")
        var callCount = 0
        sut.onUpdate = {
            callCount += 1
            if callCount == 2 { expectation.fulfill() }
        }

        sut.loadOffers()
        waitForExpectations(timeout: 1)

        XCTAssertFalse(sut.offers.isEmpty)
    }
}
