import Foundation

final class BotManager {

    private let bots: [TradingBot]
    private let wallet: Wallet
    private let group = DispatchGroup()
    private let resultsQueue = DispatchQueue(label: "botmanager.results.queue")
    private var allResults: [DayResult] = []

    init(bots: [TradingBot], wallet: Wallet) {
        self.bots = bots
        self.wallet = wallet
    }

    func runAll(completion: @escaping ([DayResult]) -> Void) {
        allResults = []

        for day in 1...AppConfig.tradingDaysCount {
            for bot in bots {
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    let result = bot.runDay(day: day, wallet: self.wallet)
                    self.resultsQueue.async {
                        self.allResults.append(result)
                        self.group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let sorted = self.allResults.sorted {
                if $0.day != $1.day { return $0.day < $1.day }
                return $0.botName < $1.botName
            }
            completion(sorted)
        }
    }
}
