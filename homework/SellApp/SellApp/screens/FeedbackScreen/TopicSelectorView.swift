import UIKit


struct FeedbackTopic {
    let id: String
    let title: String
}

protocol TopicSelectorViewDelegate: AnyObject {
    func topicSelectorView(_ view: TopicSelectorView, didUpdateSelectedTopics topics: [FeedbackTopic])
}

//
final class TopicSelectorView: UIView {

    private enum Constants {
        static let chipHeight: CGFloat = 36
        static let chipHPadding: CGFloat = 14
        static let chipSpacing: CGFloat = 8
        static let rowSpacing: CGFloat = 8
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
    private var chipButtons: [UIButton] = []
    private var lastLayoutWidth: CGFloat = 0

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Тема обращения (необязательно)"
        label.font = .systemFont(ofSize: 13)
        label.textColor = Constants.titleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.rowSpacing
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        buildChipButtons()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        guard width > 0, width != lastLayoutWidth else { return }
        lastLayoutWidth = width
        buildRows(availableWidth: width)
    }
}

// MARK: - Setup

private extension TopicSelectorView {

    func setupSubviews() {
        addSubview(titleLabel)
        addSubview(rowsStack)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            rowsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            rowsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowsStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func buildChipButtons() {
        chipButtons = topics.map { topic in
            var config = UIButton.Configuration.filled()
            config.baseForegroundColor = .white
            config.baseBackgroundColor = Constants.deselectedColor
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 8, leading: Constants.chipHPadding,
                bottom: 8, trailing: Constants.chipHPadding
            )
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
                var a = attrs
                a.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .medium)
                return a
            }
            config.title = topic.title
            var handler = config
            handler.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                Constants.deselectedColor
            }

            let button = UIButton(configuration: config)
            button.configurationUpdateHandler = { [weak self] btn in
                var c = btn.configuration
                let isSelected = self?.selectedTopics.contains(where: { $0.title == c?.title }) ?? false
                c?.baseBackgroundColor = isSelected ? Constants.selectedColor : Constants.deselectedColor
                btn.configuration = c
            }
            button.layer.cornerRadius = Constants.chipHeight / 2
            button.clipsToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: Constants.chipHeight).isActive = true
            button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            return button
        }
    }

    func buildRows(availableWidth: CGFloat) {
        rowsStack.arrangedSubviews.forEach { view in
            (view as? UIStackView)?.arrangedSubviews.forEach { $0.removeFromSuperview() }
            view.removeFromSuperview()
        }

        var currentRow = makeRowStack()
        var currentRowWidth: CGFloat = 0

        for button in chipButtons {
            let title = button.configuration?.title ?? ""
            let textWidth = (title as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: Constants.fontSize, weight: .medium)]
            ).width
            let buttonWidth = ceil(textWidth + Constants.chipHPadding * 2)
            let spacingIfNeeded = currentRowWidth > 0 ? Constants.chipSpacing : 0

            if currentRowWidth + spacingIfNeeded + buttonWidth > availableWidth, currentRowWidth > 0 {
                rowsStack.addArrangedSubview(currentRow)
                currentRow = makeRowStack()
                currentRowWidth = 0
            }

            currentRow.addArrangedSubview(button)
            currentRowWidth += (currentRowWidth > 0 ? Constants.chipSpacing : 0) + buttonWidth
        }

        if !currentRow.arrangedSubviews.isEmpty {
            rowsStack.addArrangedSubview(currentRow)
        }
    }

    func makeRowStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.chipSpacing
        stack.alignment = .center
        return stack
    }
}

// MARK: - Actions

private extension TopicSelectorView {

    @objc func chipTapped(_ sender: UIButton) {
        guard let index = chipButtons.firstIndex(of: sender) else { return }
        let topic = topics[index]

        if let existingIndex = selectedTopics.firstIndex(where: { $0.id == topic.id }) {
            selectedTopics.remove(at: existingIndex)
        } else {
            selectedTopics.append(topic)
        }

        let isSelected = selectedTopics.contains(where: { $0.id == topic.id })
        UIView.animate(withDuration: 0.2) {
            var config = sender.configuration
            config?.baseBackgroundColor = isSelected
                ? Constants.selectedColor
                : Constants.deselectedColor
            sender.configuration = config
        }
        chipButtons.forEach { $0.setNeedsUpdateConfiguration() }
        delegate?.topicSelectorView(self, didUpdateSelectedTopics: selectedTopics)
    }
}
