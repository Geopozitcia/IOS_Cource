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

    @State private var authorName: String = ""
    @State private var messageText: String = ""
    @State private var isAgreed: Bool = false
    @State private var showAgreement: Bool = false

    var body: some View {
        ZStack {
            mainContent
            if showAgreement {
                agreementOverlay
            }
        }
        .background(Constants.background)
    }

// MARK: - Main form
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                nameField
                messageField
                checkboxRow
                sendButton
            }
            .padding(Constants.padding)
        }
    }

    private var nameField: some View {
        TextField("", text: $authorName)
            .placeholder(when: authorName.isEmpty) {
                Text("Ваше имя").foregroundColor(.gray)
            }
            .foregroundColor(.white)
            .padding(14)
            .background(Constants.fieldBackground)
            .cornerRadius(Constants.cornerRadius)
    }

    private var messageField: some View {
        ZStack(alignment: .topLeading) {
            if messageText.isEmpty {
                Text("Текст обращения")
                    .foregroundColor(.gray)
                    .padding(14)
            }
            TextEditor(text: $messageText)
                .foregroundColor(.white)
                .frame(minHeight: Constants.messageMinHeight)
                .padding(10)
                .scrollContentBackground(.hidden)
        }
        .background(Constants.fieldBackground)
        .cornerRadius(Constants.cornerRadius)
    }

    private var checkboxRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(isAgreed ? .blue : .gray)
                .onTapGesture { isAgreed.toggle() }

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
            // no logic for now
        }) {
            Text("Отправить")
                .font(.system(size: Constants.buttonFontSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isAgreed ? Color.blue : Color.gray.opacity(0.5))
                .cornerRadius(Constants.buttonCornerRadius)
        }
        .disabled(!isAgreed)
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
