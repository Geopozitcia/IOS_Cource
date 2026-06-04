import Foundation

final class P2PDataMapper {

    private enum Constants {
        static let discountRange: ClosedRange<Double> = 0.95...0.99
        static let reserveRange: ClosedRange<Double> = 100...10000
        static let sellerNames = [
            "CryptoKing", "FastTrader", "P2PMaster",
            "CoinSwap", "SafeExchange", "TrustPeer",
            "QuickDeal", "AlphaTrader", "BitBroker"
        ]
    }

    func mapToOffers(from dto: P2PExchangeRateDTO) -> [P2POffer] {
        return Constants.sellerNames.map { name in
            let discount = Double.random(in: Constants.discountRange)
            let rate = dto.rate * discount
            let reserve = Double.random(in: Constants.reserveRange)
            return P2POffer(sellerName: name, rate: rate, reserve: reserve)
        }.sorted { $0.rate > $1.rate }
    }
}
