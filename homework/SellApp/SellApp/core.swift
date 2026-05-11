import Foundation

// MARK: - Protocol

protocol Tradable {
    var currency: String { get }
    var currentPrice: Double { get }
    func priceDescription() -> String
}

struct P2POffer {
    let sellerName: String
    let rate: Double
    let reserve: Double
}

// MARK: - TradeAction

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

// MARK: - PriceQuote

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

// MARK: - DayResult

struct DayResult {
    let botName: String
    let pair: String
    let day: Int
    let income: Double

    var description: String {
        let sign = income >= 0 ? "+" : ""
        return "\(botName) (\(pair)), day = \(day), income = \(sign)\(String(format: "%.1f", income))"
    }
}

// MARK: - TradeRecord

struct TradeRecord {
    let id: UUID
    let action: TradeAction
    let priceDescription: String
    let incomeDescription: String?

    init(action: TradeAction, priceDescription: String) {
        self.id = UUID()
        self.action = action
        self.priceDescription = priceDescription

        switch action {
        case .sell(let income):
            self.incomeDescription = "INCOME = \(String(format: "%.1f", income))"
        default:
            self.incomeDescription = nil
        }
    }
}

// MARK: - TradingBot

final class TradingBot {

    let name: String
    let fromCurrency: String
    let toCurrency: String

    private var previousPrice: Double = 0.0
    private var currentDeal: Double? = nil

    var pair: String { return "\(fromCurrency)-\(toCurrency)" }

    init(name: String, fromCurrency: String, toCurrency: String) {
        self.name = name
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
    }

    func runDay(day: Int, wallet: Wallet) -> DayResult {
        let operationsCount = Int.random(
            in: AppConfig.minOperationsPerDay...AppConfig.maxOperationsPerDay
        )

        previousPrice = 0.0
        currentDeal = nil

        let startBalance = wallet.balance(for: toCurrency)
        var dayIncome: Double = 0.0

        for _ in 0..<operationsCount {
            let quote = PriceQuote(currency: fromCurrency, currentPrice: randomPrice())
            let action = determineAction(for: quote)

            switch action {
            case .buy:
                wallet.deduct(amount: quote.currentPrice, currency: fromCurrency)
                wallet.deposit(amount: quote.currentPrice, currency: toCurrency)
            case .sell(let income):
                wallet.deposit(amount: income, currency: toCurrency)
                dayIncome += income
            default:
                break
            }

            if case .open = action { continue }
            previousPrice = quote.currentPrice
        }

        let endBalance = wallet.balance(for: toCurrency)
        let totalIncome = endBalance - startBalance

        return DayResult(botName: name, pair: pair, day: day, income: totalIncome)
    }
}

// MARK: - TradingBot Private

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
}

// MARK: - CustomStringConvertible

extension TradingBot: CustomStringConvertible {
    var description: String {
        return "TradingBot[\(name)] | Pair: \(pair)"
    }
}
