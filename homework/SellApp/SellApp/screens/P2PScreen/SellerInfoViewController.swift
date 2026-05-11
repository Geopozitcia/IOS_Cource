import UIKit

final class SellerInfoViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 10
        static let avatarSize: CGFloat = 80
        static let titleFontSize: CGFloat = 22
        static let labelFontSize: CGFloat = 15
        static let smallFontSize: CGFloat = 13
        static let cardSpacing: CGFloat = 12
    }

    private let offer: P2POffer

    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = Constants.avatarSize / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let rateRow = SellerInfoViewController.makeRow(title: "Rate", icon: "arrow.left.arrow.right")
    private let reserveRow = SellerInfoViewController.makeRow(title: "Reserve", icon: "banknote")
    private let dealsRow = SellerInfoViewController.makeRow(title: "Deals completed", icon: "checkmark.seal")
    private let ratingRow = SellerInfoViewController.makeRow(title: "Rating", icon: "star.fill")
    private let verifiedRow = SellerInfoViewController.makeRow(title: "Verified", icon: "shield.checkered")

    private let cardStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.cardSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(offer: P2POffer) {
        self.offer = offer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seller Info"
        setupBackground()
        setupSubviews()
        setupConstraints()
        configure()
    }
}

// MARK: - Setup

private extension SellerInfoViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    func setupSubviews() {
        avatarView.addSubview(avatarLabel)

        cardStack.addArrangedSubview(rateRow)
        cardStack.addArrangedSubview(reserveRow)
        cardStack.addArrangedSubview(dealsRow)
        cardStack.addArrangedSubview(ratingRow)
        cardStack.addArrangedSubview(verifiedRow)

        infoCard.addSubview(cardStack)

        view.addSubview(avatarView)
        view.addSubview(nameLabel)
        view.addSubview(infoCard)
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            avatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            nameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            infoCard.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            infoCard.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            infoCard.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            cardStack.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: Constants.padding),
            cardStack.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -Constants.padding),
            cardStack.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: Constants.padding),
            cardStack.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -Constants.padding)
        ])
    }

    func configure() {
        avatarLabel.text = String(offer.sellerName.prefix(1))
        nameLabel.text = offer.sellerName

        setRowValue(rateRow, value: String(format: "%.4f", offer.rate))
        setRowValue(reserveRow, value: String(format: "%.2f", offer.reserve))
        setRowValue(dealsRow, value: "\(Int.random(in: 50...2000))")
        setRowValue(ratingRow, value: String(format: "%.1f ★", Double.random(in: 4.0...5.0)))
        setRowValue(verifiedRow, value: Bool.random() ? "Yes ✓" : "No")
    }

    func setRowValue(_ row: UIView, value: String) {
        guard let valueLabel = row.viewWithTag(2) as? UILabel else { return }
        valueLabel.text = value
    }

    static func makeRow(title: String, icon: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Constants.labelFontSize)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.tag = 2
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }
}
