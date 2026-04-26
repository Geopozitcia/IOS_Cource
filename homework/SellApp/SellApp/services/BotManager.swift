import Foundation

final class BotManager {
    private let wallet: Wallet
    private var bots: [TradingBot] = []
    
    init(wallet: Wallet) {
        self.wallet = wallet
    }
    
    func setupBots() {
        let pairs = [("USD", "BTC"), ("RUB", "ETH")]
        bots = []
        
        for pair in pairs {
            let botCount = (pair.0 == "USD") ? 5 : 3
            for i in 1...botCount {
                let newBot = TradingBot(
                    name: "Bot\(pair.1)\(i)",
                    fromCurrency: pair.0,
                    toCurrency: pair.1,
                    wallet: wallet
                )
                bots.append(newBot)
            }
        }
    }
    
    func runSimulation(completion: @escaping ([TradeRecord]) -> Void) {
            let group = DispatchGroup()
            let resultQueue = DispatchQueue(label: "com.tradingbot.results", attributes: .concurrent)
            var allRecords: [TradeRecord] = []
            
            for bot in bots {
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    for day in 1...AppConfig.tradingDaysCount {
                        let record = bot.runDay(dayNumber: day)
                        
                        resultQueue.async(flags: .barrier) {
                            allRecords.append(contentsOf: record)
                        }
                    }
                    resultQueue.async(flags: .barrier) {
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                let sortedRecords = allRecords.sorted { $0.priceDescription < $1.priceDescription }
                completion(sortedRecords)
            }
        }
}
