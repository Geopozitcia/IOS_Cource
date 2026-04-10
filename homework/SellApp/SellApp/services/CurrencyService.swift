// Generates currencies list. Computing differnces beetwen couple values.
import Foundation

enum CurrencyType {
    case fiat
    case crypto
    case all
}

final class CurrencyService {

    static let shared = CurrencyService() // singleton object

    private(set) var currencies: [String] = []
    private(set) var fiatCurrencies: [String] = []
    private(set) var cryptoCurrencies: [String] = []
    private var rates: [String: Double] = [:]
    private(set) var favorites: Set<String> = []

    // known fiat currencies
    private let knownFiats: Set<String> = ["USD", "EUR", "RUB", "GBP", "JPY", "CNY", "CHF", "AUD", "CAD"]

    private init() {
        let generated = generateCurrencies(count: 120)
        currencies = generated
        fiatCurrencies = generated.filter { knownFiats.contains($0) }
        cryptoCurrencies = generated.filter { !knownFiats.contains($0) }
        refreshRates()
    }

    func rate(from: String, to: String) -> Double {
        let key = "\(from)-\(to)"
        return rates[key] ?? 0.0
    }

    func currencies(for type: CurrencyType) -> [String] {
        switch type {
        case .all:
            return currencies
        case .fiat:
            return fiatCurrencies
        case .crypto:
            return cryptoCurrencies
        }
    }

    func toggleFavorite(_ currency: String) {
        if favorites.contains(currency) {
            favorites.remove(currency)
        } else {
            favorites.insert(currency)
        }
    }

    func isFavorite(_ currency: String) -> Bool {
        return favorites.contains(currency)
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
        var result: Set<String> = ["USD", "BTC", "ETH", "EUR", "RUB", "GBP", "JPY", "CNY"]

        while result.count < count {
            let length = Int.random(in: 3...5)
            let name = String((0..<length).map { _ in letters.randomElement()! })
            result.insert(name)
        }

        return Array(result).sorted()
    }
}
