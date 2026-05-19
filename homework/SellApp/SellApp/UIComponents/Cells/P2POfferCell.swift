import UIKit

final class P2POfferCell: UITableViewCell {

    static let reuseId = "P2POfferCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let nameFontSize: CGFloat = 15
        static let rateFontSize: CGFloat = 17
        static let detailFontSize: CGFloat = 12
        static let verticalMargin: CGFloat = 4
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let sellerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.nameFontSize, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let reserveLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.detailFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.rateFontSize, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pairLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.detailFontSize)
        label.textColor = .systemGray
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

    func configure(sellerName: String, rate: Double, reserve: Double, from: String, to: String) {
        sellerNameLabel.text = sellerName
        reserveLabel.text = "Reserve: \(String(format: "%.2f", reserve)) \(to)"
        rateLabel.text = String(format: "%.4f", rate)
        pairLabel.text = "\(from) → \(to)"
    }
}

private extension P2POfferCell {

    func setupSubviews() {
        containerView.addSubview(sellerNameLabel)
        containerView.addSubview(reserveLabel)
        containerView.addSubview(rateLabel)
        containerView.addSubview(pairLabel)
        contentView.addSubview(containerView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalMargin),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalMargin),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),

            sellerNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            sellerNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            sellerNameLabel.trailingAnchor.constraint(equalTo: rateLabel.leadingAnchor, constant: -8),

            reserveLabel.topAnchor.constraint(equalTo: sellerNameLabel.bottomAnchor, constant: 4),
            reserveLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            reserveLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.padding),

            rateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            rateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),
            rateLabel.widthAnchor.constraint(equalToConstant: 100),

            pairLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 4),
            pairLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),
            pairLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.padding)
        ])
    }
}
