import UIKit

protocol FavoritesFilterViewDelegate: AnyObject {
    func didToggleFavoritesFilter(isOn: Bool)
}

final class FavoritesFilterView: UIView {

    private enum Constants {
        static let padding: CGFloat = 12
        static let cornerRadius: CGFloat = 10
        static let fontSize: CGFloat = 15
    }

    weak var delegate: FavoritesFilterViewDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorites"
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .systemBlue
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        layer.cornerRadius = Constants.cornerRadius
        setupSubviews()
        setupConstraints()
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension FavoritesFilterView {

    func setupSubviews() {
        addSubview(titleLabel)
        addSubview(toggle)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding)
        ])
    }

    @objc func switchChanged() {
        delegate?.didToggleFavoritesFilter(isOn: toggle.isOn)
    }
}
