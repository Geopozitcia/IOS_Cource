import SwiftUI

// MARK: - Models

enum SwipeDirection: CaseIterable {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop

    var instruction: String {
        switch self {
        case .leftToRight: return "слева направо →"
        case .rightToLeft: return "← справа налево"
        case .topToBottom: return "сверху вниз ↓"
        case .bottomToTop: return "↑ снизу вверх"
        }
    }
}

// MARK: - Swipe Field View

struct SwipeFieldView: View {

    let onSwipe: (SwipeDirection) -> Void

    @State private var fieldColor: Color = Color(red: 0.18, green: 0.18, blue: 0.18)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(fieldColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                )
                .animation(.easeOut(duration: 0.3), value: fieldColor)

            Text("Проведите пальцем здесь")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.5))
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { _ in
                    fieldColor = Color.blue.opacity(0.3)
                }
                .onEnded { value in
                    fieldColor = Color(red: 0.18, green: 0.18, blue: 0.18)
                    onSwipe(detectDirection(value))
                }
        )
    }

    private func detectDirection(_ value: DragGesture.Value) -> SwipeDirection {
        let dx = value.translation.width
        let dy = value.translation.height
        if abs(dx) > abs(dy) {
            return dx > 0 ? .leftToRight : .rightToLeft
        } else {
            return dy > 0 ? .topToBottom : .bottomToTop
        }
    }
}

struct CaptchaOverlayView: View {

    let onSuccess: () -> Void
    let onFailure: () -> Void

    private enum Constants {
        static let totalSteps = 3
        static let fieldHeight: CGFloat = 180
        static let cornerRadius: CGFloat = 20
        static let cardBackground = Color(red: 0.18, green: 0.18, blue: 0.18)
        static let baseFieldColor = Color(red: 0.18, green: 0.18, blue: 0.18)
    }

    @State private var steps: [SwipeDirection] = []
    @State private var currentStep = 0
    @State private var stepResults: [Bool] = []
    @State private var instructionOpacity: Double = 1.0
    @State private var fieldFeedbackColor: Color = Constants.baseFieldColor
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                VStack(spacing: 6) {
                    Text("Проверка на робота")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("Шаг \(min(currentStep + 1, Constants.totalSteps)) из \(Constants.totalSteps)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                if currentStep < Constants.totalSteps {
                    VStack(spacing: 6) {
                        Text("Следующая команда:")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)

                        Text(steps.indices.contains(currentStep) ? steps[currentStep].instruction : "")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .opacity(instructionOpacity)
                            .animation(.easeInOut(duration: 0.25), value: instructionOpacity)
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(fieldFeedbackColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                        )
                        .animation(.easeOut(duration: 0.35), value: fieldFeedbackColor)

                    Text("Проведите пальцем здесь")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(height: Constants.fieldHeight)
                .padding(.horizontal, 8)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { _ in
                            guard !isProcessing else { return }
                            fieldFeedbackColor = Color.blue.opacity(0.25)
                        }
                        .onEnded { value in
                            guard !isProcessing else { return }
                            fieldFeedbackColor = Constants.baseFieldColor
                            handleSwipe(detectDirection(value))
                        }
                )

                Button("Отмена") {
                    onFailure()
                }
                .font(.system(size: 15))
                .foregroundColor(.gray)
            }
            .padding(28)
            .background(Constants.cardBackground)
            .cornerRadius(Constants.cornerRadius)
            .padding(.horizontal, 24)
        }
        .onAppear {
            steps = Array(SwipeDirection.allCases.shuffled().prefix(Constants.totalSteps))
        }
    }


    private func detectDirection(_ value: DragGesture.Value) -> SwipeDirection {
        let dx = value.translation.width
        let dy = value.translation.height
        if abs(dx) > abs(dy) {
            return dx > 0 ? .leftToRight : .rightToLeft
        } else {
            return dy > 0 ? .topToBottom : .bottomToTop
        }
    }

    private func handleSwipe(_ direction: SwipeDirection) {
        guard currentStep < steps.count, !isProcessing else { return }

        isProcessing = true
        let correct = direction == steps[currentStep]
        stepResults.append(correct)
        withAnimation(.easeOut(duration: 0.2)) {
            fieldFeedbackColor = correct ? Color.green.opacity(0.35) : Color.red.opacity(0.35) // corect or not
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.25)) {
                fieldFeedbackColor = Constants.baseFieldColor
            }

            let nextStep = currentStep + 1

            if nextStep >= Constants.totalSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if stepResults.allSatisfy({ $0 }) {
                        onSuccess()
                    } else {
                        onFailure()
                    }
                }
            } else {
                withAnimation(.easeOut(duration: 0.15)) {
                    instructionOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    currentStep = nextStep
                    withAnimation(.easeIn(duration: 0.2)) {
                        instructionOpacity = 1.0
                    }
                    isProcessing = false
                }
            }
        }
    }
}
