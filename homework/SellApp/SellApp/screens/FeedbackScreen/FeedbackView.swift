import SwiftUI

struct FeedbackView: View {

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 24
        static let fieldBackground = Color(red: 0.2, green: 0.2, blue: 0.2)
        static let background = Color(red: 0.12, green: 0.12, blue: 0.12)
        static let messageMinHeight: CGFloat = 120
        static let buttonCornerRadius: CGFloat = 12
        static let fontSize: CGFloat = 15
        static let buttonFontSize: CGFloat = 17
    }

    @StateObject private var viewModel = FeedbackViewModel()
    @FocusState private var focusedField: FeedbackField?
    @State private var showAgreement: Bool = false
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            mainContent

            if showAgreement {
                agreementOverlay
            }

            if viewModel.showCaptcha { // overlay
                CaptchaOverlayView(
                    onSuccess: {
                        viewModel.onCaptchaSuccess()
                    },
                    onFailure: {
                        viewModel.onCaptchaFailure()
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
                .zIndex(10)
            }
        }
        .background(Constants.background)
        .onChange(of: focusedField) { oldField, newField in
            if let lost = oldField {
                viewModel.didEndEditing(field: lost)
            }
            if let gained = newField {
                viewModel.didBeginEditing(field: gained)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .alert("Сообщение отправлено", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                viewModel.resetAfterSuccess()
            }
        } message: {
            Text("Обращение принято")
        }
        // capcha failed
        .alert("Проверка не пройдена", isPresented: $viewModel.showFailureAlert) {
            Button("Попробовать ещё раз", role: .cancel) { }
        } message: {
            Text("Попробуйте снова.")
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showCaptcha)
    }

    // MARK: - Main content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                nameField
                messageField
                characterCounter
                topicSelector
                checkboxRow
                sendButton
            }
            .padding(Constants.padding)
        }
    }

    // MARK: - Name field

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("", text: $viewModel.authorName)
                .placeholder(when: viewModel.authorName.isEmpty) {
                    Text("Ваше имя").foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .padding(14)
                .background(Constants.fieldBackground)
                .cornerRadius(Constants.cornerRadius)
                .focused($focusedField, equals: .name)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(borderColor(for: viewModel.nameError, field: .name), lineWidth: 1.5)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.nameError)
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                )

            if let error = viewModel.nameError {
                errorLabel(error)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.nameError)
    }

    // MARK: - Message field

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                if viewModel.messageText.isEmpty {
                    Text("Текст обращения")
                        .foregroundColor(.gray)
                        .padding(14)
                }
                TextEditor(text: $viewModel.messageText)
                    .foregroundColor(.white)
                    .frame(minHeight: Constants.messageMinHeight)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .message)
            }
            .background(Constants.fieldBackground)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor(for: viewModel.messageError, field: .message), lineWidth: 1.5)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.messageError)
                    .animation(.easeInOut(duration: 0.2), value: focusedField)
            )

            if let error = viewModel.messageError {
                errorLabel(error)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.messageError)
    }

    private var characterCounter: some View {
        HStack {
            Spacer()
            let count = viewModel.messageText.count
            Text("\(count) / 150")
                .font(.system(size: 12))
                .foregroundColor(count > 150 ? .red : .gray)
                .animation(.easeInOut(duration: 0.2), value: count > 150)
        }
    }

    // MARK: - Topic selector

    private var topicSelector: some View {
        TopicSelectorRepresentable(selectedTopics: $viewModel.selectedTopics)
            .frame(minHeight: 80)
    }

    // MARK: - Checkbox

    private var checkboxRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: viewModel.isAgreed ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(viewModel.isAgreed ? .blue : .gray)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isAgreed)
                .onTapGesture {
                    focusedField = nil
                    viewModel.isAgreed.toggle()
                }

            consentText
        }
    }

    private var consentText: some View {
        HStack(spacing: 0) {
            Text("Я согласен на ")
                .foregroundColor(.white)
                .font(.system(size: Constants.fontSize))
            Text("обработку данных")
                .foregroundColor(.blue)
                .underline()
                .font(.system(size: Constants.fontSize))
                .onTapGesture { showAgreement = true }
        }
    }

    // MARK: - Send button

    private var sendButton: some View {
        Button(action: {
            focusedField = nil
            // Анимация нажатия
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                buttonScale = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    buttonScale = 1.0
                }
            }
            viewModel.requestSubmit()
        }) {
            Text("Отправить")
                .font(.system(size: Constants.buttonFontSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.isSubmitEnabled
                        ? Color.blue
                        : Color.gray.opacity(0.4)
                )
                .cornerRadius(Constants.buttonCornerRadius)
        }
        .disabled(!viewModel.isSubmitEnabled)
        .scaleEffect(buttonScale)
        .animation(.easeInOut(duration: 0.35), value: viewModel.isSubmitEnabled)
    }

    // MARK: - Agreement overlay

    private var agreementOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { showAgreement = false }
            VStack(spacing: 0) {
                agreementHeader
                Divider().background(Color.gray.opacity(0.4))
                ScrollView {
                    Text(Self.agreementText)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(6)
                        .padding(20)
                }
            }
            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .frame(maxHeight: 480)
        }
    }

    private var agreementHeader: some View {
        HStack {
            Text("Соглашение об обработке персональных данных")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
            Button(action: { showAgreement = false }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Helpers

    private func borderColor(for error: String?, field: FeedbackField) -> Color {
        if focusedField == field { return .blue }
        if error != nil { return .red }
        return .clear
    }

    private func errorLabel(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.red)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.red)
        }
    }

    private static let agreementText = """
        My features form with a change in the weather
        We can
        We can work it out
        My features form with a change in the weather
        We can
        We can work it out
        When the wind blows
        When the mothers talk
        When the wind blows
        When the wind blows
        When the mothers talk
        When the wind blows
        We can work it out

        ----

        It's not that you're not good enough
        It's just that we can make you better
        Given that you pay the price
        We can keep you young and tender
        Following the footsteps of a funeral pyre
        You were paid not to listen now your house is on fire

        ----

        Wake me up when things get started
        When everything starts to happen

        ----

        My features form with a change in the weather
        We can
        We can work it out
        My features form with a change in the weather
        We can
        We can work it out
        """
}

private extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .topLeading) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    FeedbackView()
}
