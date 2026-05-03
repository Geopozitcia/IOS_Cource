import UIKit
import Combine

final class AuthViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 24
        static let fieldHeight: CGFloat = 52
        static let buttonHeight: CGFloat = 52
        static let cornerRadius: CGFloat = 12
        static let titleFontSize: CGFloat = 28
        static let fieldFontSize: CGFloat = 16
        static let buttonFontSize: CGFloat = 17
        static let hintFontSize: CGFloat = 13
        static let logoSize: CGFloat = 80
        static let spacing: CGFloat = 16
        static let minFieldLength = 4
    }

    private enum Mode {
        case login
        case register

        var title: String {
            switch self {
            case .login: return "Sign In"
            case .register: return "Register"
            }
        }

        var buttonTitle: String {
            switch self {
            case .login: return "Sign In"
            case .register: return "Register"
            }
        }
    }

    var onSuccess: (() -> Void)?

    private var mode: Mode = .login
    private var cancellables = Set<AnyCancellable>()

    // Published свойства — источники данных для Combine
    @Published private var loginText: String = ""
    @Published private var passwordText: String = ""

    private let darkColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    private let cardColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)

    private let logoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = Constants.logoSize / 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "₿"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginField: UITextField = {
        let field = UITextField()
        field.placeholder = "Login (min 4 characters)"
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password (min 4 characters)"
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        button.layer.cornerRadius = Constants.cornerRadius
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let modeSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Sign In", "Register"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let validationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.hintFontSize)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.hintFontSize)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSubviews()
        setupConstraints()
        setupCombine()
        updateModeUI()
    }
}

// MARK: - Setup

private extension AuthViewController {

    func setupBackground() {
        view.backgroundColor = darkColor
    }

    func setupSubviews() {
        logoView.addSubview(logoLabel)
        setupTextField(loginField)
        setupTextField(passwordField)

        loginField.addTarget(self, action: #selector(loginChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        modeSegment.addTarget(self, action: #selector(modeSwitched), for: .valueChanged)

        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(loginField)
        view.addSubview(passwordField)
        view.addSubview(validationLabel)
        view.addSubview(actionButton)
        view.addSubview(modeSegment)
        view.addSubview(hintLabel)
    }

    func setupTextField(_ field: UITextField) {
        field.backgroundColor = cardColor
        field.textColor = .white
        field.tintColor = .systemBlue
        field.layer.cornerRadius = Constants.cornerRadius
        field.font = .systemFont(ofSize: Constants.fieldFontSize)
        field.attributedPlaceholder = NSAttributedString(
            string: field.placeholder ?? "",
            attributes: [.foregroundColor: UIColor.systemGray]
        )
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 48),
            logoView.widthAnchor.constraint(equalToConstant: Constants.logoSize),
            logoView.heightAnchor.constraint(equalToConstant: Constants.logoSize),

            logoLabel.centerXAnchor.constraint(equalTo: logoView.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: Constants.spacing),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            loginField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.spacing * 2),
            loginField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            loginField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            loginField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),

            passwordField.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: Constants.spacing),
            passwordField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            passwordField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            passwordField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),

            validationLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            validationLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            validationLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            actionButton.topAnchor.constraint(equalTo: validationLabel.bottomAnchor, constant: Constants.spacing),
            actionButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            actionButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),

            modeSegment.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: Constants.spacing),
            modeSegment.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            modeSegment.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            hintLabel.topAnchor.constraint(equalTo: modeSegment.bottomAnchor, constant: 8),
            hintLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            hintLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding)
        ])
    }

    // MARK: - Combine

    func setupCombine() {
        // Combine pipeline — кнопка активна только когда оба поля валидны
        Publishers.CombineLatest($loginText, $passwordText)
            .map { login, password in
                login.count >= Constants.minFieldLength &&
                password.count >= Constants.minFieldLength
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.actionButton.isEnabled = isValid
                self?.actionButton.alpha = isValid ? 1.0 : 0.5
            }
            .store(in: &cancellables)
    }

    func updateModeUI() {
        titleLabel.text = mode.title
        actionButton.setTitle(mode.buttonTitle, for: .normal)
        validationLabel.isHidden = true

        switch mode {
        case .login:
            hintLabel.text = "Don't have an account? Switch to Register"
        case .register:
            hintLabel.text = "Already registered? Switch to Sign In"
        }
    }

    func showValidationMessage(_ message: String, isError: Bool = true) {
        validationLabel.text = message
        validationLabel.textColor = isError ? .systemRed : .systemGreen
        validationLabel.isHidden = false
    }
}

// MARK: - Actions

private extension AuthViewController {

    @objc func loginChanged(_ field: UITextField) {
        loginText = field.text ?? ""
    }

    @objc func passwordChanged(_ field: UITextField) {
        passwordText = field.text ?? ""
    }

    @objc func modeSwitched() {
        mode = modeSegment.selectedSegmentIndex == 0 ? .login : .register
        updateModeUI()
    }

    @objc func actionTapped() {
        let login = loginField.text ?? ""
        let password = passwordField.text ?? ""

        switch mode {
        case .register:
            _ = AuthService.shared.register(login: login, password: password)
            showValidationMessage("Registered! You can now sign in.", isError: false)
            modeSegment.selectedSegmentIndex = 0
            mode = .login
            updateModeUI()

        case .login:
            if AuthService.shared.login(login: login, password: password) {
                onSuccess?()
            } else {
                showValidationMessage("Invalid login or password")
            }
        }
    }
}
