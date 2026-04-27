import Foundation

struct CandleModel {

    let open: Double
    let close: Double
    let high: Double
    let low: Double

    var isBullish: Bool {
        return close >= open
    }

    var bodyHeight: Double {
        return abs(close - open)
    }

    var wickHeight: Double {
        return high - low
    }

    static func random() -> CandleModel {
        let open = Double.random(in: 50...150)
        let close = Double.random(in: 50...150)
        let high = max(open, close) + Double.random(in: 5...30)
        let low = min(open, close) - Double.random(in: 5...30)
        return CandleModel(open: open, close: close, high: high, low: low)
    }

    static func generateList(count: Int = 30) -> [CandleModel] {
        return (0..<count).map { _ in CandleModel.random() }
    }
}
