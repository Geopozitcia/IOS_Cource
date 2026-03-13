import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

var balance: Double = 100
var currentPrice: Double
var previousPrice: Double = 0.0
var currentDeal: Double? = nil
let currency = "USDT"

for _ in 0..<15 {
    currentPrice = Double.random(in: 50.0...70.0)
    
    if previousPrice == 0 { // случай при первом выставлении цены
        print("BIDDINGS ARE OPEN\n")
        previousPrice = currentPrice
        Thread.sleep(forTimeInterval: 1.0)
        continue
    }
    
    if currentPrice > previousPrice { // бот продает товар, если цена на него выросла;
        if currentDeal != nil {
            let income = currentPrice - currentDeal!
            balance += income
            print("\(String(format: "%.1f", currentPrice)) \(currency) - SELLING\n")
            print("SOLD FROM = \(String(format: "%.1f", currentDeal!)) -> TO \(String(format: "%.1f", currentPrice)), INCOME = \(String(format: "%.1f", income))\n")
            currentDeal = nil
        } else {
            print("\(String(format: "%.1f", currentPrice)) \(currency) - IGNORE\n")
        }
    } else { // покупает если упала
        if currentDeal == nil {
            currentDeal = currentPrice
            print("\(String(format: "%.1f", currentPrice)) \(currency) - BUYING\n")
        } else {
            print("\(String(format: "%.1f", currentPrice)) \(currency) - IGNORE\n")
        }
    }
    
    previousPrice = currentPrice
    Thread.sleep(forTimeInterval: 1.0)
}

if balance > 100 {
    print("Bot earned \(String(format: "%.1f", balance - 100)) \(currency)")
} else {
    print("Bot lost \(String(format: "%.1f", 100 - balance)) \(currency)")
}

// есть ли способ форматрирвоать вывод double проще?
