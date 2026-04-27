import UIKit

final class DayResultCell: UITableViewCell {

    static let reuseId = "DayResultCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 10
        static let horizontalPadding: CGFloat = 16
        static let fontSize: CGFloat = 13
        static let dayFontSize: CGFloat = 11
    }

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let botNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.dayFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let incomeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .bold)
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

    func configure(with result: DayResult) {
        botNameLabel.text = "\(result.botName) (\(result.pair))"
        dayLabel.text = "Day \(result.day)"

        let sign = result.income >= 0 ? "+" : ""
        incomeLabel.text = "\(sign)\(String(format: "%.1f", result.income))"
        incomeLabel.textColor = result.income >= 0 ? .systemGreen : .systemRed

        containerView.backgroundColor = result.income >= 0
            ? UIColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 1)
            : UIColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 1)
    }
}

private extension DayResultCell {

    func setupSubviews() {
        containerView.addSubview(botNameLabel)
        containerView.addSubview(dayLabel)
        containerView.addSubview(incomeLabel)
        contentView.addSubview(containerView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),

            botNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            botNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            botNameLabel.trailingAnchor.constraint(equalTo: incomeLabel.leadingAnchor, constant: -8),

            dayLabel.topAnchor.constraint(equalTo: botNameLabel.bottomAnchor, constant: 4),
            dayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            dayLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.padding),

            incomeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            incomeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),
            incomeLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}
