import UIKit

struct FeedbackTopic: Equatable {
    let id: String
    let title: String
}

protocol TopicSelectorViewDelegate: AnyObject {
    func topicSelectorView(_ view: TopicSelectorView, didUpdateSelectedTopics topics: [FeedbackTopic])
}

private final class TopicChipCell: UICollectionViewCell {

    static let reuseId = "TopicChipCell"

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, isSelected: Bool) {
        label.text = title
        contentView.backgroundColor = isSelected
            ? .systemBlue
            : UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    }
}

// MARK: - TopicSelectorView

final class TopicSelectorView: UIView {

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
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(TopicChipCell.self, forCellWithReuseIdentifier: TopicChipCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UICollectionViewDataSource

extension TopicSelectorView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopicChipCell.reuseId,
            for: indexPath
        ) as? TopicChipCell else { return UICollectionViewCell() }

        let topic = topics[indexPath.item]
        let isSelected = selectedTopics.contains(topic)
        cell.configure(title: topic.title, isSelected: isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TopicSelectorView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topic = topics[indexPath.item]

        if let index = selectedTopics.firstIndex(of: topic) {
            selectedTopics.remove(at: index)
        } else {
            selectedTopics.append(topic)
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? TopicChipCell {
            let isSelected = selectedTopics.contains(topic)
            UIView.animate(withDuration: 0.2) {
                cell.configure(title: topic.title, isSelected: isSelected)
            }
        }

        delegate?.topicSelectorView(self, didUpdateSelectedTopics: selectedTopics)
    }
}
