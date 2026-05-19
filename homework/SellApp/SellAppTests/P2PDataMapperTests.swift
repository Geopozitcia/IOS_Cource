import XCTest
@testable import SellApp

final class P2PDataMapperTests: XCTestCase {

    private var sut: P2PDataMapper!

    override func setUp() {
        super.setUp()
        sut = P2PDataMapper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_mapToOffers_returnsCorrectCount() {
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "EUR", rate: 0.92)
        let offers = sut.mapToOffers(from: dto)
        XCTAssertEqual(offers.count, 9)
    }

    func test_mapToOffers_ratesAreLowerThanBase() {
        let baseRate = 1.0
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "EUR", rate: baseRate)
        let offers = sut.mapToOffers(from: dto)
        offers.forEach { offer in
            XCTAssertLessThanOrEqual(offer.rate, baseRate)
        }
    }

    func test_mapToOffers_sortedByRateDescending() {
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "EUR", rate: 0.92)
        let offers = sut.mapToOffers(from: dto)
        for i in 0..<offers.count - 1 {
            XCTAssertGreaterThanOrEqual(offers[i].rate, offers[i + 1].rate)
        }
    }

    func test_mapToOffers_reserveIsPositive() {
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "EUR", rate: 0.92)
        let offers = sut.mapToOffers(from: dto)
        offers.forEach { offer in
            XCTAssertGreaterThan(offer.reserve, 0)
        }
    }

    func test_mapToOffers_sellerNamesAreNotEmpty() {
        let dto = P2PExchangeRateDTO(fromCurrency: "USD", toCurrency: "EUR", rate: 0.92)
        let offers = sut.mapToOffers(from: dto)
        offers.forEach { offer in
            XCTAssertFalse(offer.sellerName.isEmpty)
        }
    }
}
