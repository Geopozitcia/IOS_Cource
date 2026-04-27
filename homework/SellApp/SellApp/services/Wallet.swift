import Foundation

final class Wallet {

    private var balances: [String: Double] = [:]
    private var credits: [String: Double] = [:]
    private let queue = DispatchQueue(label: "wallet.queue", attributes: .concurrent)

    init(currencies: [String]) {
        for currency in currencies {
            balances[currency] = AppConfig.initialBalance
            credits[currency] = 0.0
        }
    }

    func balance(for currency: String) -> Double {
        return queue.sync {
            return balances[currency] ?? 0.0
        }
    }

    func credit(for currency: String) -> Double {
        return queue.sync {
            return credits[currency] ?? 0.0
        }
    }

    func deduct(amount: Double, currency: String) {
        queue.async(flags: .barrier) {
            let current = self.balances[currency] ?? 0.0
            self.balances[currency] = current - amount
            self.refillIfNeeded(currency: currency)
        }
    }

    func deposit(amount: Double, currency: String) {
        queue.async(flags: .barrier) {
            let current = self.balances[currency] ?? 0.0
            self.balances[currency] = current + amount
        }
    }

    func snapshot() -> [String: Double] {
        return queue.sync {
            return balances
        }
    }
}

private extension Wallet {

    func refillIfNeeded(currency: String) {
        let current = balances[currency] ?? 0.0
        if current <= 0 {
            balances[currency] = (balances[currency] ?? 0.0) + AppConfig.creditTopUpAmount
            credits[currency] = (credits[currency] ?? 0.0) + AppConfig.creditTopUpAmount
        }
    }
}
