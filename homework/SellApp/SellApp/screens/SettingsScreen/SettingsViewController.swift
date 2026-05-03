import UIKit

final class SettingsViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 24
        static let buttonHeight: CGFloat = 52
        static let buttonCornerRadius: CGFloat = 12
        static let buttonFontSize: CGFloat = 17
        static let titleFontSize: CGFloat = 16
    }

    var onLogout: (() -> Void)?

    private let darkColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)

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
    }
}

// MARK: - Setup

private extension SettingsViewController {

    func setupBackground() {
        view.backgroundColor = darkColor
    }

    func setupSubviews() {
        view.addSubview(logoutButton)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            logoutButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            logoutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}

// MARK: - Actions

private extension SettingsViewController {

    @objc func logoutTapped() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            AuthService.shared.logout()
            self?.onLogout?()
        })
        present(alert, animated: true)
    }
}
