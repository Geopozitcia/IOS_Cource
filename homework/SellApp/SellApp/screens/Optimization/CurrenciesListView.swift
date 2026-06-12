import Foundation
import SwiftUI
import UIKit
import Combine

struct CurrencyPair: Identifiable, Equatable {
    let id: UUID
    let name: String
    var value: Double
    var previousValue: Double
    var history: [Double]

    var changePercent: Double {
        guard previousValue != 0 else { return 0 }
        return (value - previousValue) / previousValue * 100
    }
}


struct PreparedPairData: Equatable {
    let price: AttributedString
    let volatility: Double
    let rsi: Double
    let valueAtRisk: Double
    let isRisky: Bool   // volatility > 0.12

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.volatility == rhs.volatility &&
        lhs.rsi == rhs.rsi &&
        lhs.valueAtRisk == rhs.valueAtRisk
    }
}


@MainActor
final class CurrencyPairsGenerator: ObservableObject {
    static let pairsCount = 500

    /// prepare() is nonisolated so it can be called from background threads in use cases
    nonisolated static func prepare(pair: CurrencyPair) -> PreparedPairData {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 6

        let priceText = formatter.string(from: NSNumber(value: pair.value)) ?? "\(pair.value)"
        let attributedText = NSMutableAttributedString(
            string: priceText,
            attributes: [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: pair.value >= pair.previousValue
                    ? UIColor.systemGreen : UIColor.systemRed
            ]
        )

        let history = pair.history
        var returns: [Double] = []
        if history.count > 1 {
            for i in 1..<history.count {
                returns.append(log(history[i] / max(history[i - 1], 0.0001)))
            }
        }

        let avgReturn = returns.reduce(0, +) / Double(max(returns.count, 1))
        let variance = returns.reduce(0) { $0 + pow($1 - avgReturn, 2) } / Double(max(returns.count, 1))
        let volatility = sqrt(variance) * sqrt(252)

        var gains = 0.0, losses = 0.0
        let startIndex = max(1, history.count - 14)
        if history.count > 1 {
            for i in startIndex..<history.count {
                let diff = history[i] - history[i - 1]
                diff >= 0 ? (gains += diff) : (losses += abs(diff))
            }
        }
        let rsi: Double = losses == 0 ? 100 : 100 - 100 / (1 + gains / losses)

        var simulatedLosses: [Double] = []
        for path in 0..<900 {
            var simulatedPrice = pair.value
            for step in 0..<30 {
                let noise = sin(Double(path * 31 + step * 17))
                    * cos(Double(step + abs(pair.name.hashValue % 1000)))
                simulatedPrice *= exp(avgReturn + volatility * 0.02 * noise)
            }
            simulatedLosses.append(pair.value - simulatedPrice)
        }
        simulatedLosses.sort()
        let valueAtRisk = simulatedLosses[min(simulatedLosses.count - 1, Int(Double(simulatedLosses.count) * 0.95))]

        return PreparedPairData(
            price: AttributedString(attributedText),
            volatility: volatility,
            rsi: rsi,
            valueAtRisk: valueAtRisk,
            isRisky: volatility > 0.04
        )
    }

    nonisolated static func makePairs() -> [CurrencyPair] {
        (0..<pairsCount).map { _ in
            var value = Double.random(in: 0.5...180)
            var history: [Double] = []
            for _ in 0..<120 {
                value = max(0.0001, value * Double.random(in: 0.995...1.005))
                history.append(value)
            }
            return CurrencyPair(
                id: UUID(),
                name: "\(randomCode())/\(randomCode())",
                value: value,
                previousValue: history.dropLast().last ?? value,
                history: history
            )
        }
    }

    nonisolated static func randomCode() -> String {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return String((0..<3).map { _ in letters.randomElement()! })
    }
}

// MARK: - UDF State

enum CurrencyPairsState {
    case empty
    case loading
    case content(CurrencyPairsContent)
    case error(String)
}

struct CurrencyPairsContent: Equatable {
    var pairs: [CurrencyPair]
    var lastUpdatedPairs: [CurrencyPair]
    var preparedData: [UUID: PreparedPairData]
    var updateCycle: Int
}

// MARK: - UDF Actions

enum CurrencyPairsAction {
    case appear
    case loaded([CurrencyPair], [UUID: PreparedPairData])
    case tick([CurrencyPair], [CurrencyPair], [UUID: PreparedPairData])
    case failed(String)
}

@MainActor
final class CurrencyPairsViewModel: ObservableObject {
    @Published var state: CurrencyPairsState = .empty

    private let loadPairsUseCase: LoadCurrencyPairsUseCase
    private let updatePairsUseCase: UpdateCurrencyPairsUseCase
    private var timer: Timer?

    init(
        loadPairsUseCase: LoadCurrencyPairsUseCase = .init(),
        updatePairsUseCase: UpdateCurrencyPairsUseCase = .init()
    ) {
        self.loadPairsUseCase = loadPairsUseCase
        self.updatePairsUseCase = updatePairsUseCase
    }

    func dispatch(_ action: CurrencyPairsAction) {
        reduce(action)

        switch action {
        case .appear:
            loadPairs()
        case .loaded:
            startTimer()
        case .tick, .failed:
            break
        }
    }
}

private extension CurrencyPairsViewModel {

    func reduce(_ action: CurrencyPairsAction) {
        switch action {
        case .appear:
            state = .loading

        case .loaded(let pairs, let prepared):
            let content = CurrencyPairsContent(
                pairs: pairs,
                lastUpdatedPairs: Array(pairs.prefix(12)), // all data computing only once
                preparedData: prepared,
                updateCycle: 0
            )
            state = .content(content)

        case .tick(let updatedPairs, let lastUpdated, let newPrepared):
            guard case .content(var content) = state else { return }
            content.pairs = updatedPairs
            content.lastUpdatedPairs = lastUpdated
            content.preparedData.merge(newPrepared) { _, new in new } // recomputing only when changing
            content.updateCycle += 1
            state = .content(content)

        case .failed(let message):
            state = .error(message)
        }
    }

    func loadPairs() {
        loadPairsUseCase.execute { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let (pairs, prepared)):
                self.dispatch(.loaded(pairs, prepared))
            case .failure(let error):
                self.dispatch(.failed(error.localizedDescription))
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self else { return }
            MainActor.assumeIsolated {
                self.tickUpdate()
            }
        }
    }

    func tickUpdate() {
        guard case .content(let content) = state else { return }
        let result = updatePairsUseCase.execute(
            currentPairs: content.pairs,
            currentPrepared: content.preparedData
        )
        dispatch(.tick(result.updatedPairs, result.lastUpdated, result.newPrepared))
    }
}

// MARK: - Use Cases

final class LoadCurrencyPairsUseCase {

    func execute(completion: @escaping (Result<([CurrencyPair], [UUID: PreparedPairData]), Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let pairs = CurrencyPairsGenerator.makePairs()
            let prepared = Dictionary(
                uniqueKeysWithValues: pairs.map { ($0.id, CurrencyPairsGenerator.prepare(pair: $0)) }
            )
            DispatchQueue.main.async {
                completion(.success((pairs, prepared)))
            }
        }
    }
}

struct PairsUpdateResult {
    let updatedPairs: [CurrencyPair]
    let lastUpdated: [CurrencyPair]
    let newPrepared: [UUID: PreparedPairData]
}

final class UpdateCurrencyPairsUseCase {

    func execute(currentPairs: [CurrencyPair], currentPrepared: [UUID: PreparedPairData]) -> PairsUpdateResult {
        var updatedPairs = currentPairs
        let updateCount = Int.random(in: 8...35)
        var indexes = Set<Int>()

        while indexes.count < updateCount {
            indexes.insert(Int.random(in: updatedPairs.indices))
        }

        for index in indexes {
            updatedPairs[index].previousValue = updatedPairs[index].value
            updatedPairs[index].value = max(
                0.0001,
                updatedPairs[index].value * Double.random(in: 0.985...1.015)
            )
            updatedPairs[index].history.append(updatedPairs[index].value)

            if updatedPairs[index].history.count > 240 {
                updatedPairs[index].history.removeFirst(
                    updatedPairs[index].history.count - 240
                )
            }
        }

        var newPrepared: [UUID: PreparedPairData] = [:]
        for index in indexes {
            let pair = updatedPairs[index]
            newPrepared[pair.id] = CurrencyPairsGenerator.prepare(pair: pair)
        }

        let lastUpdated = indexes.sorted().map { updatedPairs[$0] }

        return PairsUpdateResult(
            updatedPairs: updatedPairs,
            lastUpdated: lastUpdated,
            newPrepared: newPrepared
        )
    }
}

/// Removed Equatable extencion with id constants  Now view get correct data with each update
struct RecentUpdatedPairsView: View {
    let lastUpdatedPairs: [CurrencyPair]
    let updateCycle: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Последние обновления")
                .font(.headline)
                .padding(.horizontal, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(lastUpdatedPairs) { pair in
                        RecentCurrencyPairCard(pair: pair)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .padding(.top, 12)
        .background(Color.black.opacity(0.04))
    }
}

struct CurrencyPairsView: View {
    @StateObject private var viewModel = CurrencyPairsViewModel()
    @State private var highlightRisk: Bool = false

    var body: some View {
        switch viewModel.state {
        case .empty:
            Color.clear
                .onAppear { viewModel.dispatch(.appear) }

        case .loading:
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                    .scaleEffect(1.4)
                Text("Loading pairs...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .onAppear { viewModel.dispatch(.appear) }

        case .content(let content):
            /// lazy stack was replace with scroll view + v stack. Toggle and RecentUpdatedPairsView visable now
            ScrollView {
                VStack(spacing: 0) {
                    Toggle("Подсвечивать рискованные пары", isOn: $highlightRisk)
                        .padding()
                        .background(Color.gray.opacity(0.12))

                    RecentUpdatedPairsView(
                        lastUpdatedPairs: content.lastUpdatedPairs,
                        updateCycle: content.updateCycle
                    )

                    LazyVStack(spacing: 10) {
                        ForEach(content.pairs) { pair in
                            if let prepared = content.preparedData[pair.id] {
                                /// .id(UUID()) removed
                                PairRowView(
                                    pair: pair,
                                    prepared: prepared,
                                    highlightRisk: highlightRisk
                                )
                                .equatable()
                                /// isRisky  precomputing in prepared.
                            }
                        }
                    }
                    .padding(.vertical, 12)
                }
            }

        case .error(let message):
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text("Load failed: \(message)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
        }
    }
}

struct PairRowView: View, Equatable {
    let pair: CurrencyPair
    let prepared: PreparedPairData
    let highlightRisk: Bool

    /// SwiftUI calling body only when return false
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.pair.id == rhs.pair.id &&
        lhs.pair.value == rhs.pair.value &&
        lhs.highlightRisk == rhs.highlightRisk &&
        lhs.prepared == rhs.prepared
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(pair.name)
                    .font(.headline)
                Text(prepared.price)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("RSI \(prepared.rsi, specifier: "%.2f")")
                Text("Vol \(prepared.volatility, specifier: "%.4f")")
                Text("VaR \(prepared.valueAtRisk, specifier: "%.4f")")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    highlightRisk && prepared.isRisky
                        ? Color.yellow.opacity(0.45)
                        : Color.gray.opacity(0.12)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 8)
        .padding(.horizontal, 12)
        .animation(.easeInOut(duration: 0.2), value: pair.value)
    }
}

/// eliminated checksum
struct RecentCurrencyPairCard: View {
    let pair: CurrencyPair

    var body: some View {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 5

        let price = formatter.string(from: NSNumber(value: pair.value)) ?? "\(pair.value)"
        let isGrowing = pair.value >= pair.previousValue

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pair.name)
                    .font(.caption.bold())
                Spacer()
                Circle()
                    .fill(isGrowing ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
            }

            Text(price)
                .font(.system(size: 17, weight: .semibold, design: .monospaced))

            Text("\(pair.changePercent, specifier: "%.2f")%")
                .font(.caption)
                .foregroundColor(isGrowing ? .green : .red)
        }
        .frame(width: 150, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 8)
    }
}
