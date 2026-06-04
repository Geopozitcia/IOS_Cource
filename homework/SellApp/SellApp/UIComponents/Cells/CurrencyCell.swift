// cell for UICollectionView.
// Show currency name and change appear.

import UIKit

protocol CurrencyCellDelegate: AnyObject {
    func didToggleFavorite(currency: String)
}

final class CurrencyCell: UICollectionViewCell {

    static let reuseId = "CurrencyCell"

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let fontSize: CGFloat = 14
        static let padding: CGFloat = 8
        static let starSize: CGFloat = 20
        static let borderWidth: CGFloat = 2
        // animation
        static let selectionScaleSmall: CGFloat = 0.88
        static let selectionScaleDuration: TimeInterval = 0.12
        static let selectionFlashDuration: TimeInterval = 0.15
        static let selectionFadeDuration: TimeInterval = 0.3
    }

    weak var delegate: CurrencyCellDelegate?
    private var currency: String = ""

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let starButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.cornerRadius
        setupSubviews()
        setupConstraints()
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        starButton.setImage(UIImage(systemName: "star"), for: .normal)
        starButton.tintColor = .systemGray
        layer.borderWidth = 0
        nameLabel.textColor = .white
        backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
    }

    func configure(with currency: String, isDisabled: Bool, isSelected: Bool = false, isFavorite: Bool = false) {
        self.currency = currency
        nameLabel.text = currency

        starButton.setImage(
            UIImage(systemName: isFavorite ? "star.fill" : "star"),
            for: .normal
        )
        starButton.tintColor = isFavorite ? .systemYellow : .systemGray

        if isDisabled {
            backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            nameLabel.textColor = .systemGray
            layer.borderWidth = 0
        } else if isSelected {
            backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
            nameLabel.textColor = .systemBlue
            layer.borderWidth = Constants.borderWidth
            layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
            nameLabel.textColor = .white
            layer.borderWidth = 0
        }
    }
    
    func animateSelection() {
        UIView.animate( // scaling
            withDuration: Constants.selectionScaleDuration,
            animations: {
                self.transform = CGAffineTransform(scaleX: Constants.selectionScaleSmall, y: Constants.selectionScaleSmall)
            },
            completion: { _ in
                UIView.animate(withDuration: Constants.selectionScaleDuration) {
                    self.transform = .identity
                }
            }
        )

        UIView.animate( // flashing
            withDuration: Constants.selectionFlashDuration,
            animations: {
                self.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
            },
            completion: { _ in
                UIView.animate(withDuration: Constants.selectionFadeDuration) {
                    self.backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
                }
            }
        )
    }
}

private extension CurrencyCell {

    func setupSubviews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(starButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            starButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            starButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            starButton.widthAnchor.constraint(equalToConstant: Constants.starSize),
            starButton.heightAnchor.constraint(equalToConstant: Constants.starSize),

            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc func starTapped() {
        delegate?.didToggleFavorite(currency: currency)
    }
}
