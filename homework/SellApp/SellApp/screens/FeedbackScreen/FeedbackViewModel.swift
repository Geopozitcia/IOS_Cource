import Foundation
import SwiftUI
import Combine

final class FeedbackViewModel: ObservableObject {

    @Published var authorName: String = ""
    @Published var messageText: String = ""
    @Published var isAgreed: Bool = false
    @Published var selectedTopics: [FeedbackTopic] = []
    @Published private(set) var nameError: String? = nil
    @Published private(set) var messageError: String? = nil
    @Published private(set) var isSubmitEnabled: Bool = false
    @Published private(set) var isSubmitted: Bool = false

    // Captcha
    @Published var showCaptcha: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showFailureAlert: Bool = false

    @AppStorage("feedback.lastAuthorName") var savedAuthorName: String = ""
    private var cancellables = Set<AnyCancellable>()

    private enum Validation {
        static let minLength = 3
        static let maxNameLength = 30
        static let maxMessageLength = 150
    }

    init() {
        if !savedAuthorName.isEmpty {
            authorName = savedAuthorName
        }
        setupSubmitPipeline()
    }

    // MARK: - Public

    func didBeginEditing(field: FeedbackField) {
        switch field {
        case .name:    nameError = nil
        case .message: messageError = nil
        }
    }

    func didEndEditing(field: FeedbackField) {
        switch field {
        case .name:    nameError = validateName(authorName)
        case .message: messageError = validateMessage(messageText)
        }
    }

    func requestSubmit() {
        guard isSubmitEnabled else { return }
        showCaptcha = true
    }

    func onCaptchaSuccess() {
        showCaptcha = false
        savedAuthorName = authorName
        isSubmitted = true
        showSuccessAlert = true
    }

    func onCaptchaFailure() {
        showCaptcha = false
        showFailureAlert = true
    }

    func resetAfterSuccess() {
        authorName = savedAuthorName
        messageText = ""
        isAgreed = false
        isSubmitted = false
        nameError = nil
        messageError = nil
        selectedTopics = []
    }

    func reset() {
        messageText = ""
        isAgreed = false
        isSubmitted = false
        nameError = nil
        messageError = nil
        selectedTopics = []
    }
}

enum FeedbackField: Hashable {
    case name
    case message
}

// MARK: - Private

private extension FeedbackViewModel {

    func validateName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Поле «Имя» не должно быть пустым" }
        if trimmed.count < Validation.minLength {
            return "Имя должно содержать не менее \(Validation.minLength) символов"
        }
        if trimmed.count > Validation.maxNameLength {
            return "Имя не должно превышать \(Validation.maxNameLength) символов"
        }
        return nil
    }

    func validateMessage(_ message: String) -> String? {
        let trimmed = message.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Текст обращения не должен быть пустым" }
        if trimmed.count < Validation.minLength {
            return "Текст обращения должен содержать не менее \(Validation.minLength) символов"
        }
        if trimmed.count > Validation.maxMessageLength {
            return "Текст обращения не должен превышать \(Validation.maxMessageLength) символов"
        }
        return nil
    }

    func setupSubmitPipeline() {
        Publishers.CombineLatest3($authorName, $messageText, $isAgreed)
            .map { [weak self] name, message, agreed in
                guard let self else { return false }
                return self.validateName(name) == nil
                    && self.validateMessage(message) == nil
                    && agreed
            }
            .assign(to: &$isSubmitEnabled)
    }
}
