// Generates currencies list. Computing differnces beetwen couple values.


import Foundation

final class CurrencyService {

    static let shared = CurrencyService() // singleton object

    private(set) var currencies: [String] = []
    private var rates: [String: Double] = [:]

    private init() {
        currencies = generateCurrencies(count: 120)
        refreshRates()
    }

    func rate(from: String, to: String) -> Double {
        let key = "\(from)-\(to)"
        return rates[key] ?? 0.0
    }

    func refreshRates() {
        for from in currencies {
            for to in currencies where to != from {
                let key = "\(from)-\(to)"
                rates[key] = Double.random(in: 0.0001...100.0) 
            }
        }
    }
}

private extension CurrencyService {

    func generateCurrencies(count: Int) -> [String] {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        var result: Set<String> = ["USD", "BTC", "ETH", "EUR", "RUB"]

        while result.count < count {
            let length = Int.random(in: 3...5)
            let name = String((0..<length).map { _ in letters.randomElement()! })
            result.insert(name)
        }

        return Array(result).sorted()
    }
}
