import SwiftUI

struct CryptoToken {
    let ticker: String
    let price: String
    let percentChange: Double
}

struct ContentView: View {
    
    let tokens: [CryptoToken] = [
        CryptoToken(ticker: "BTC", price: "$65,230", percentChange: 4.2),
        CryptoToken(ticker: "ETH", price: "$3,450", percentChange: 2.8),
        CryptoToken(ticker: "SOL", price: "$152.3", percentChange: -5.1),
        CryptoToken(ticker: "BNB", price: "$580.2", percentChange: 0.5),
        CryptoToken(ticker: "ADA", price: "$0.45", percentChange: -3.2),
        CryptoToken(ticker: "XRP", price: "$0.52", percentChange: 1.1),
        CryptoToken(ticker: "DOT", price: "$6.8", percentChange: -6.4),
        CryptoToken(ticker: "DOGE", price: "$0.14", percentChange: 12.3),
        CryptoToken(ticker: "AVAX", price: "$34.1", percentChange: -2.1),
        CryptoToken(ticker: "LINK", price: "$14.5", percentChange: -1.8),
        CryptoToken(ticker: "TON", price: "$7.2", percentChange: 8.6)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Market Heatmap")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
                .background(Color.gray.opacity(10))
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    tokenCell(for: tokens[0])
                    VStack(spacing: 4) {
                        tokenCell(for: tokens[1])
                        tokenCell(for: tokens[3])
                    }
                }
                .frame(maxHeight: 220)
                
                HStack(spacing: 4) {
                    tokenCell(for: tokens[2])
                    tokenCell(for: tokens[7])
                    VStack(spacing: 4) {
                        tokenCell(for: tokens[10])
                        tokenCell(for: tokens[6])
                    }
                }
                .frame(maxHeight: 180)
                
                HStack(spacing: 4) {
                    tokenCell(for: tokens[4])
                    tokenCell(for: tokens[5])
                    tokenCell(for: tokens[8])
                    tokenCell(for: tokens[9])
                }
                .frame(maxHeight: 120)
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(.top)
        .background(Color.black)
        .onAppear {
        }
    }
    
    func tokenCell(for token: CryptoToken) -> some View {
        // percent of grown/fall with abs
        let changeValue = abs(token.percentChange)
        let calculatedSize = 12.0 + (changeValue * 0.5)
        let finalFontSize = max(11.0, min(calculatedSize, 18.0))
        let isPositive = token.percentChange >= 0
        let sign = isPositive ? "+" : ""
        
        return VStack(alignment: .leading) {
            HStack {
                Text(token.ticker)
                    .font(.system(size: finalFontSize, weight: .bold))
                Spacer()
                Text("\(sign)\(String(format: "%.1f", token.percentChange))%")
                    .font(.system(size: finalFontSize * 0.8, weight: .medium))
            }
            
            Spacer()
            
            Text(token.price)
                .font(.system(size: finalFontSize * 0.9, weight: .semibold))
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isPositive ? Color.green.opacity(0.85) : Color.red.opacity(0.85))
        .foregroundColor(.white)
    }
}

// это правда очень удобно
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
