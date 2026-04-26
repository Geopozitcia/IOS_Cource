import Foundation

final class Wallet {
    private var balances: [String: Double] = [:]
    private var totalCredits: [String: Double] = [:]
    private let queue = DispatchQueue(label: "com.trading.wallet.queue", attributes: .concurrent)

    init(currencies: [String]) {
        for currency in currencies {
            balances[currency] = 1000.0
            totalCredits[currency] = 0.0
        }
    }

    // MARK: - Thread-Safe Getters
    func balance(for currency: String) -> Double {
        queue.sync { balances[currency] ?? 0.0 }
    }

    func credit(for currency: String) -> Double {
        queue.sync { totalCredits[currency] ?? 0.0 }
    }

    // MARK: - Mutating Methods
    func deduct(amount: Double, currency: String) -> Bool {
        queue.sync(flags: .barrier) {
            let currentBalance = balances[currency] ?? 0.0
            if currentBalance < amount {
                refill(currency: currency, amount: amount)
            }
            
            balances[currency] = (balances[currency] ?? 0.0) - amount
            return true
        }
    }

    func deposit(amount: Double, currency: String) {
        queue.sync(flags: .barrier) {
            let current = balances[currency] ?? 0.0
            balances[currency] = current + amount
        }
    }

    func netProfit(for currency: String) -> Double {
        queue.sync {
            let current = balances[currency] ?? 0.0
            let credit = totalCredits[currency] ?? 0.0
            return current - credit
        }
    }

    func snapshot() -> [String: Double] {
        queue.sync { balances }
    }
}

// MARK: - Private Logic
private extension Wallet {
    func refill(currency: String, amount: Double) {
        let topUp = max(amount, 500.0)
        balances[currency] = (balances[currency] ?? 0.0) + topUp
        totalCredits[currency] = (totalCredits[currency] ?? 0.0) + topUp
    
    }
}
