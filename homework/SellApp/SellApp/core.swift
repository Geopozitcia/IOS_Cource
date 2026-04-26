import Foundation

// MARK: - Protocols & Enums
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
        case .open: return "BIDDINGS ARE OPEN"
        case .buy: return "BUYING"
        case .sell: return "SELLING"
        case .ignore: return "IGNORE"
        }
    }
}

// MARK: - Models
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
            let prefix = income >= 0 ? "+" : ""
            self.incomeDescription = "income = \(prefix)\(String(format: "%.1f", income))"
        default:
            self.incomeDescription = nil
        }
    }
}

// MARK: - TradingBot (new)
final class TradingBot {
    let name: String
    private let fromCurrency: String
    private let toCurrency: String
    private let wallet: Wallet
    
    private var previousPrice: Double = 0.0
    private var currentDealPrice: Double? = nil

    init(name: String, fromCurrency: String, toCurrency: String, wallet: Wallet) {
        self.name = name
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.wallet = wallet
    }

    func runDay(dayNumber: Int) -> [TradeRecord] {
        var dailyRecords: [TradeRecord] = []
        let operationsCount = Int.random(in: AppConfig.minOperationsPerDay...AppConfig.maxOperationsPerDay)
        for _ in 0..<operationsCount {
            let quote = PriceQuote(currency: toCurrency, currentPrice: randomPrice())
            let action = determineAction(for: quote)
            let description = "\(name) (\(fromCurrency)-\(toCurrency)), day = \(dayNumber)"
            let record = TradeRecord(action: action, priceDescription: description)
            dailyRecords.append(record)
        }

        return dailyRecords
    }
}

// MARK: - Private Logic
private extension TradingBot {
    
    func randomPrice() -> Double {
        return Double.random(in: 50.0...150.0)
    }

    func determineAction(for quote: PriceQuote) -> TradeAction {
        if previousPrice == 0 {
            previousPrice = quote.currentPrice
            return .open
        }
        
        let action: TradeAction
        if quote.currentPrice > previousPrice {
            action = handlePriceRise(quote)
        } else if quote.currentPrice < previousPrice {
            action = handlePriceDrop(quote)
        } else {
            action = .ignore
        }
        
        previousPrice = quote.currentPrice
        return action
    }

    func handlePriceRise(_ quote: PriceQuote) -> TradeAction {
        if let buyPrice = currentDealPrice {
            let income = quote.currentPrice - buyPrice
            
            wallet.deduct(amount: 1.0, currency: toCurrency)
            wallet.deposit(amount: quote.currentPrice, currency: fromCurrency)
            
            currentDealPrice = nil
            return .sell(income: income)
        }
        return .ignore
    }

    func handlePriceDrop(_ quote: PriceQuote) -> TradeAction {
        if currentDealPrice == nil {
            currentDealPrice = quote.currentPrice
            
            wallet.deduct(amount: quote.currentPrice, currency: fromCurrency)
            wallet.deposit(amount: 1.0, currency: toCurrency)
            
            return .buy
        }
        return .ignore
    }
}

extension TradingBot: CustomStringConvertible {
    var description: String {
        return "Bot: \(name) | Pair: \(fromCurrency)-\(toCurrency)"
    }
}
