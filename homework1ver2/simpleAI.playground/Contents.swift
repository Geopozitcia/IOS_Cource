import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


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
        String(format: "%.1f", currentPrice)
    }

    func priceDescription() -> String {
        "\(priceFormatted) \(currency)"
    }
}


class TradingBot {
    private let currency: String
    private var balance: Double
    private var previousPrice: Double = 0.0
    private var currentDeal: Double? = nil
    private let totalIterations: Int

    var profit: Double { balance - 100 }
    var isProfit: Bool { balance > 100 }

    init(currency: String = "USDT", startBalance: Double = 100, iterations: Int = 15) {
        self.currency = currency
        self.balance = startBalance
        self.totalIterations = iterations
    }

    private func randomPrice() -> Double {
        Double.random(in: 50.0...70.0)
    }

    private func handleFirstPrice(_ quote: PriceQuote) -> TradeAction {
        previousPrice = quote.currentPrice
        return .open
    }

    private func handlePriceRise(_ quote: PriceQuote) -> TradeAction {
        if let deal = currentDeal {
            let income = quote.currentPrice - deal
            balance += income
            currentDeal = nil
            return .sell(income: income)
        }
        return .ignore
    }

    private func handlePriceDrop(_ quote: PriceQuote) -> TradeAction {
        if currentDeal == nil {
            currentDeal = quote.currentPrice
            return .buy
        }
        return .ignore
    }

    private func determineAction(for quote: PriceQuote) -> TradeAction {
        if previousPrice == 0 {
            return handleFirstPrice(quote)
        }
        if quote.currentPrice > previousPrice {
            return handlePriceRise(quote)
        } else {
            return handlePriceDrop(quote)
        }
    }

    private func log(quote: PriceQuote, action: TradeAction) {
        switch action {
        case .open:
            print("\(action.description)\n")
        case .sell(let income):
            print("\(quote.priceDescription()) - \(action.description)\n")
            print("SOLD FROM = \(String(format: "%.1f", currentDeal ?? quote.currentPrice)) -> TO \(quote.priceFormatted), INCOME = \(String(format: "%.1f", income))\n")
        default:
            print("\(quote.priceDescription()) - \(action.description)\n")
        }
    }


    func run() {
        for _ in 0..<totalIterations {
            let quote = PriceQuote(currency: currency, currentPrice: randomPrice())
            let action = determineAction(for: quote)
            log(quote: quote, action: action)

            if case .open = action {
                Thread.sleep(forTimeInterval: 1.0)
                continue
            }

            previousPrice = quote.currentPrice
            Thread.sleep(forTimeInterval: 1.0)
        }

        printResult()
    }

    private func printResult() {
        if isProfit {
            print("Bot earned \(String(format: "%.1f", profit)) \(currency)")
        } else {
            print("Bot lost \(String(format: "%.1f", -profit)) \(currency)")
        }
    }
}


extension TradingBot: CustomStringConvertible {
    var description: String {
        "TradingBot | Currency: \(currency) | Balance: \(String(format: "%.1f", balance))"
    }
}

let bot = TradingBot()
bot.run()
