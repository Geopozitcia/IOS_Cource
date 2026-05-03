import UIKit

final class SettingsViewController: UIViewController {
    
    private enum Constants {
        static let padding: CGFloat = 24
        static let buttonHeight: CGFloat = 52
        static let buttonCornerRadius: CGFloat = 12
        static let buttonFontSize: CGFloat = 17
        static let spacing: CGFloat = 20
    }
    
    var onLogout: (() -> Void)?
    private let darkColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    
    private let autoLoginStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let autoLoginLabel: UILabel = {
        let label = UILabel()
        label.text = "Auto-login"
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.buttonFontSize)
        return label
    }()
    
    private let autoLoginSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .systemGreen
        return sw
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupBackground()
        setupSubviews()
        setupConstraints()
        
        autoLoginSwitch.isOn = AuthService.shared.isAutoLoginEnabled
    }
}

private extension SettingsViewController {
    func setupBackground() {
        view.backgroundColor = darkColor
    }
    
    func setupSubviews() {
        view.addSubview(autoLoginStack)
        autoLoginStack.addArrangedSubview(autoLoginLabel)
        autoLoginStack.addArrangedSubview(autoLoginSwitch)
        
        view.addSubview(logoutButton)
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        autoLoginSwitch.addTarget(self, action: #selector(autoLoginChanged), for: .valueChanged)
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            autoLoginStack.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            autoLoginStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            autoLoginStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            
            logoutButton.topAnchor.constraint(equalTo: autoLoginStack.bottomAnchor, constant: Constants.spacing),
            logoutButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            logoutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    @objc func autoLoginChanged(_ sender: UISwitch) {
        AuthService.shared.isAutoLoginEnabled = sender.isOn
    }
    
    @objc func logoutTapped() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            AuthService.shared.logout()
            self?.onLogout?()
        })
        present(alert, animated: true)
    }
}
