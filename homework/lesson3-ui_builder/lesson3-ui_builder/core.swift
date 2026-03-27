import Foundation

protocol Tradable {
    var currency: String { get }
    var currentPrice: Double { get }
    func priceDescription() -> String
}

enum TradeAction {
    case buy
    case sell(income: Double)
    case ignore
    case open

    var description: String {
        switch self {
        case .open:
            return "BIDDINGS ARE OPEN"
        case .buy:
            return "BUYING"
        case .sell:
            return "SELLING"
        case .ignore:
            return "IGNORE"
        }
    }
}

struct PriceQuote: Tradable {
    let currency: String
    let currentPrice: Double

    var priceFormatted: String {
        return String(format: "%.1f", currentPrice)
    }

    func priceDescription() -> String {
        return "\(priceFormatted) \(currency)"
    }
}

final class TradingBot {
    private let currency: String
    private var balance: Double
    private var previousPrice: Double = 0.0
    private var currentDeal: Double? = nil
    private let totalIterations: Int

    var profit: Double { return balance - 100 }
    var isProfit: Bool { return balance > 100 }

    init(currency: String = "USDT", startBalance: Double = 100, iterations: Int = 15) {
        self.currency = currency
        self.balance = startBalance
        self.totalIterations = iterations
    }

    func run() -> String {
        var log = ""

        for _ in 0..<totalIterations {
            let quote = PriceQuote(currency: currency, currentPrice: randomPrice())
            let action = determineAction(for: quote)
            log += formatAction(quote: quote, action: action)

            if case .open = action { continue }
            previousPrice = quote.currentPrice
        }

        log += isProfit
            ? "\nBot earned \(String(format: "%.1f", profit)) \(currency)"
            : "\nBot lost \(String(format: "%.1f", -profit)) \(currency)"

        return log
    }
}

private extension TradingBot {

    func randomPrice() -> Double {
        return Double.random(in: 50.0...70.0)
    }

    func determineAction(for quote: PriceQuote) -> TradeAction {
        if previousPrice == 0 {
            return handleFirstPrice(quote)
        }
        if quote.currentPrice > previousPrice {
            return handlePriceRise(quote)
        } else {
            return handlePriceDrop(quote)
        }
    }

    func handleFirstPrice(_ quote: PriceQuote) -> TradeAction {
        previousPrice = quote.currentPrice
        return .open
    }

    func handlePriceRise(_ quote: PriceQuote) -> TradeAction {
        if let deal = currentDeal {
            let income = quote.currentPrice - deal
            balance += income
            currentDeal = nil
            return .sell(income: income)
        }
        return .ignore
    }

    func handlePriceDrop(_ quote: PriceQuote) -> TradeAction {
        if currentDeal == nil {
            currentDeal = quote.currentPrice
            return .buy
        }
        return .ignore
    }

    func formatAction(quote: PriceQuote, action: TradeAction) -> String {
        switch action {
        case .open:
            return "\(action.description)\n"
        case .sell(let income):
            return "\(quote.priceDescription()) - SELLING\nINCOME = \(String(format: "%.1f", income))\n"
        default:
            return "\(quote.priceDescription()) - \(action.description)\n"
        }
    }
}

extension TradingBot: CustomStringConvertible {
    var description: String {
        return "TradingBot | Currency: \(currency) | Balance: \(String(format: "%.1f", balance))"
    }
}
