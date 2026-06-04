import UIKit

struct FeedbackTopic {
    let id: String
    let title: String
}

protocol TopicSelectorViewDelegate: AnyObject {
    func topicSelectorView(_ view: TopicSelectorView, didUpdateSelectedTopics topics: [FeedbackTopic])
}

final class TopicSelectorView: UIView {

    private enum Constants {
        static let chipHeight: CGFloat = 36
        static let chipHPadding: CGFloat = 14
        static let chipVPadding: CGFloat = 8
        static let chipSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 18
        static let fontSize: CGFloat = 14
        static let titleColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        static let selectedColor = UIColor.systemBlue
        static let deselectedColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    }

    weak var delegate: TopicSelectorViewDelegate?

    private let topics: [FeedbackTopic] = [
        FeedbackTopic(id: "withdrawal", title: "Проблема с выводом"),
        FeedbackTopic(id: "bot",        title: "Проблема с ботом"),
        FeedbackTopic(id: "p2p",        title: "P2P продавец не отвечает"),
        FeedbackTopic(id: "account",    title: "Проблема с аккаунтом"),
        FeedbackTopic(id: "payment",    title: "Не прошёл платёж"),
        FeedbackTopic(id: "other",      title: "Другое"),
    ]

    private(set) var selectedTopics: [FeedbackTopic] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Тема обращения (необязательно)"
        label.font = .systemFont(ofSize: 13)
        label.textColor = Constants.titleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chipsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var chipButtons: [UIButton] = []
    private var chipsContainerHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        buildChips()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let containerWidth = bounds.width
        guard containerWidth > 0 else { return }
        let height = layoutChips(containerWidth: containerWidth)
        if chipsContainerHeightConstraint.constant != height {
            chipsContainerHeightConstraint.constant = height
            DispatchQueue.main.async {
                self.superview?.setNeedsLayout()
                self.superview?.layoutIfNeeded()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let chipsHeight = layoutChips(containerWidth: bounds.width)
        let height = bounds.width > 0 ? chipsHeight : 44
        return CGSize(width: UIView.noIntrinsicMetric, height: 20 + height)
    }
}

private extension TopicSelectorView {

    func setupSubviews() {
        addSubview(titleLabel)
        addSubview(chipsContainer)
    }

    func setupConstraints() {
        chipsContainerHeightConstraint = chipsContainer.heightAnchor.constraint(equalToConstant: 44)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            chipsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chipsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            chipsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            chipsContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            chipsContainerHeightConstraint
        ])
    }

    func buildChips() {
        chipButtons = topics.map { topic in
            var config = UIButton.Configuration.filled()
            config.title = topic.title
            config.baseForegroundColor = .white
            config.baseBackgroundColor = Constants.deselectedColor
            config.contentInsets = NSDirectionalEdgeInsets(
                top: Constants.chipVPadding,
                leading: Constants.chipHPadding,
                bottom: Constants.chipVPadding,
                trailing: Constants.chipHPadding
            )
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
                var updated = attrs
                updated.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .medium)
                return updated
            }

            let button = UIButton(configuration: config)
            button.layer.cornerRadius = Constants.cornerRadius
            button.clipsToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            chipsContainer.addSubview(button)
            return button
        }
    }

    @discardableResult
    func layoutChips(containerWidth: CGFloat) -> CGFloat {
        guard containerWidth > 0 else { return 44 }

        var x: CGFloat = 0
        var y: CGFloat = 0

        for (index, button) in chipButtons.enumerated() {
            let title = topics[index].title
            let textWidth = (title as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: Constants.fontSize, weight: .medium)]
            ).width
            let width = ceil(textWidth + Constants.chipHPadding * 2)

            if x + width > containerWidth && x > 0 {
                x = 0
                y += Constants.chipHeight + Constants.chipSpacing
            }

            button.frame = CGRect(x: x, y: y, width: width, height: Constants.chipHeight)
            x += width + Constants.chipSpacing
        }

        return y + Constants.chipHeight
    }
}

private extension TopicSelectorView {

    @objc func chipTapped(_ sender: UIButton) {
        guard let index = chipButtons.firstIndex(of: sender) else { return }
        let topic = topics[index]

        if let existingIndex = selectedTopics.firstIndex(where: { $0.id == topic.id }) {
            selectedTopics.remove(at: existingIndex)
            animateChip(sender, selected: false)
        } else {
            selectedTopics.append(topic)
            animateChip(sender, selected: true)
        }

        delegate?.topicSelectorView(self, didUpdateSelectedTopics: selectedTopics)
    }

    func animateChip(_ button: UIButton, selected: Bool) {
        var config = button.configuration
        config?.baseBackgroundColor = selected ? Constants.selectedColor : Constants.deselectedColor
        button.configuration = config
        button.transform = selected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
    }
}
