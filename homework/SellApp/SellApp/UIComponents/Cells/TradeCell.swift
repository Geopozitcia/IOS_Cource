import UIKit

final class TradeCell: UITableViewCell {

    static let reuseId = "TradeCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let fontSize: CGFloat = 15
        static let incomeFontSize: CGFloat = 13
        static let padding: CGFloat = 10
        static let innerPadding: CGFloat = 6
        static let incomeHeight: CGFloat = 32
    }

    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize - 2, weight: .medium)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let incomeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = Constants.innerPadding
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let incomeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: Constants.incomeFontSize, weight: .regular)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var incomeViewHeightConstraint: NSLayoutConstraint!

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

    func configure(with record: TradeRecord) {
        priceLabel.text = record.priceDescription
        actionLabel.text = record.action.description

        switch record.action {
        case .buy:
            mainView.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1)
        case .sell:
            mainView.backgroundColor = UIColor(red: 0.4, green: 0.1, blue: 0.1, alpha: 1)
        case .ignore, .open:
            mainView.backgroundColor = UIColor(red: 0.4, green: 0.35, blue: 0.0, alpha: 1)
        }

        if let income = record.incomeDescription {
            incomeLabel.text = income
            incomeViewHeightConstraint.constant = Constants.incomeHeight
            incomeView.isHidden = false
        } else {
            incomeViewHeightConstraint.constant = 0
            incomeView.isHidden = true
        }
    }
}

private extension TradeCell {

    func setupSubviews() {
        incomeView.addSubview(incomeLabel)
        mainView.addSubview(priceLabel)
        mainView.addSubview(actionLabel)
        mainView.addSubview(incomeView)
        contentView.addSubview(mainView)
    }

    func setupConstraints() {
        incomeViewHeightConstraint = incomeView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            priceLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: Constants.padding),
            priceLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),

            actionLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -12),

            incomeView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Constants.innerPadding),
            incomeView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -Constants.padding),
            incomeView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),
            incomeView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -12),
            incomeViewHeightConstraint,

            incomeLabel.centerYAnchor.constraint(equalTo: incomeView.centerYAnchor),
            incomeLabel.leadingAnchor.constraint(equalTo: incomeView.leadingAnchor, constant: 8)
        ])
    }
}
