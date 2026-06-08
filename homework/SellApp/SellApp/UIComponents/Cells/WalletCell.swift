import UIKit

final class WalletCell: UITableViewCell {

    static let reuseId = "WalletCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let currencyFontSize: CGFloat = 16
        static let balanceFontSize: CGFloat = 18
        static let creditFontSize: CGFloat = 11
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.currencyFontSize, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let creditLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.creditFontSize)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.balanceFontSize, weight: .semibold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(currency: String, balance: Double, credit: Double) {
        currencyLabel.text = currency
        balanceLabel.text = String(format: "%.2f", balance)

        if credit > 0 {
            creditLabel.text = "Credit: \(String(format: "%.2f", credit))"
            creditLabel.isHidden = false
        } else {
            creditLabel.isHidden = true
        }
    }
}

private extension WalletCell {

    func setupSubviews() {
        containerView.addSubview(currencyLabel)
        containerView.addSubview(creditLabel)
        containerView.addSubview(balanceLabel)
        contentView.addSubview(containerView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),

            currencyLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            currencyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),

            creditLabel.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor, constant: 4),
            creditLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            creditLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.padding),

            balanceLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),
            balanceLabel.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
}
