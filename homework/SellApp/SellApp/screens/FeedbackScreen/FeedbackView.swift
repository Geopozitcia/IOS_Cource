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

    var body: some View {
        ZStack {
            mainContent
            if showAgreement {
                agreementOverlay
            }
            if viewModel.isSubmitted {
                successOverlay
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
    }

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
                )

            if let error = viewModel.nameError {
                errorLabel(error)
            }
        }
    }

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
            )

            if let error = viewModel.messageError {
                errorLabel(error)
            }
        }
    }

    private var characterCounter: some View {
        HStack {
            Spacer()
            let count = viewModel.messageText.count
            Text("\(count) / 150")
                .font(.system(size: 12))
                .foregroundColor(count > 150 ? .red : .gray)
        }
    }

    private var topicSelector: some View {
        TopicSelectorRepresentable(selectedTopics: $viewModel.selectedTopics)
            .frame(minHeight: 80)
    }

    private var checkboxRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: viewModel.isAgreed ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(viewModel.isAgreed ? .blue : .gray)
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

    private var sendButton: some View {
        Button(action: {
            focusedField = nil
            viewModel.submit()
        }) {
            Text("Отправить")
                .font(.system(size: Constants.buttonFontSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.isSubmitEnabled ? Color.blue : Color.gray.opacity(0.5))
                .cornerRadius(Constants.buttonCornerRadius)
        }
        .disabled(!viewModel.isSubmitEnabled)
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Обращение отправлено")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Ты только жалуешься и жалуешься")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                Button("Закрыть") { viewModel.reset() }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.buttonCornerRadius)
            }
            .padding(Constants.padding)
            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
            .cornerRadius(20)
            .padding(.horizontal, 32)
        }
    }

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
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.2), value: text)
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
