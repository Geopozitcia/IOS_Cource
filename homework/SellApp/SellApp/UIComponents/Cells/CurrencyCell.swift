// cell for UICollectionView.
// Show currency name and change appear.

import UIKit

final class CurrencyCell: UICollectionViewCell {

    static let reuseId = "CurrencyCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let fontSize: CGFloat = 14
        static let padding: CGFloat = 8
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        layer.cornerRadius = Constants.cornerRadius
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with currency: String, isDisabled: Bool) {
        nameLabel.text = currency

        if isDisabled {
            backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            nameLabel.textColor = .systemGray
            layer.borderWidth = 0
        } else {
            backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
            nameLabel.textColor = .white
            layer.borderWidth = 0
        }
    }
}

private extension CurrencyCell {

    func setupSubviews() {
        contentView.addSubview(nameLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding)
        ])
    }
}
