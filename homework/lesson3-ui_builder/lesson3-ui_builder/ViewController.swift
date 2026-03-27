import UIKit

class ViewController: UIViewController {

    private let darkColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    private let cardColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
    private let innerColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let oldPriceLabel = UILabel()
    private let containerView = UIView()
    private let innerView = UIView()
    private let deliveryLabel = UILabel()
    private let ratingView = UIView()
    private let ratingLabel = UILabel()
    private let reviewsLabel = UILabel()
    private let hStack = UIStackView()
    private let runButton = UIButton(type: .system)
    private let logTextView = UITextView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = darkColor
        setupSubviews()
        setupConstraints()
    }
}

// MARK: - Setup

private extension ViewController {

    func setupSubviews() {
        // ImageView
        imageView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let placeholderLabel = UILabel()
        placeholderLabel.text = "UIImageView"
        placeholderLabel.textColor = .systemGray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        // Name label
        nameLabel.text = "Some Product for sale, Type A, Black"
        nameLabel.numberOfLines = 2
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Price label
        priceLabel.text = "12 990 $"
        priceLabel.font = .systemFont(ofSize: 22, weight: .bold)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Old prie
        let strikeAttr = NSAttributedString(string: "19 990 $", attributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemGray
        ])
        oldPriceLabel.attributedText = strikeAttr
        oldPriceLabel.font = .systemFont(ofSize: 15)
        oldPriceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Container view
        containerView.backgroundColor = cardColor
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false

        innerView.backgroundColor = innerColor
        innerView.layer.cornerRadius = 8
        innerView.translatesAutoresizingMaskIntoConstraints = false

        deliveryLabel.text = "Delivery: tomorrow"
        deliveryLabel.textAlignment = .center
        deliveryLabel.font = .systemFont(ofSize: 14)
        deliveryLabel.textColor = .white
        deliveryLabel.translatesAutoresizingMaskIntoConstraints = false

        innerView.addSubview(deliveryLabel)
        containerView.addSubview(innerView)

        // Rating view
        ratingView.backgroundColor = cardColor
        ratingView.layer.cornerRadius = 10
        ratingView.layer.borderWidth = 1
        ratingView.layer.borderColor = UIColor.systemGray.cgColor
        ratingView.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.text = "4.4 ★"
        ratingLabel.font = .systemFont(ofSize: 15, weight: .medium)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        reviewsLabel.text = "1513 reviews"
        reviewsLabel.font = .systemFont(ofSize: 15, weight: .medium)
        reviewsLabel.textColor = .white
        reviewsLabel.textAlignment = .center
        reviewsLabel.translatesAutoresizingMaskIntoConstraints = false

        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 8
        hStack.addArrangedSubview(ratingLabel)
        hStack.addArrangedSubview(reviewsLabel)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        ratingView.addSubview(hStack)

        // Run button
        runButton.setTitle("Run command", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = 12
        runButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        runButton.addTarget(self, action: #selector(runTapped), for: .touchUpInside)
        runButton.translatesAutoresizingMaskIntoConstraints = false

        // Log text view
        logTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        logTextView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        logTextView.layer.cornerRadius = 10
        logTextView.isEditable = false
        logTextView.textColor = .white
        logTextView.isHidden = true
        logTextView.translatesAutoresizingMaskIntoConstraints = false

        // Empty state label
        emptyLabel.text = "Нет данных"
        emptyLabel.textColor = .systemGray
        emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(priceLabel)
        view.addSubview(oldPriceLabel)
        view.addSubview(containerView)
        view.addSubview(ratingView)
        view.addSubview(runButton)
        view.addSubview(logTextView)
        view.addSubview(emptyLabel)
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([

            // ImageView
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            // Name label
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            // Price label
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),

            // Old price label
            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),

            // Container view
            containerView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 56),

            // Inner view внутри containerView
            innerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            innerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            innerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            innerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            // Delivery label внутри innerView
            deliveryLabel.topAnchor.constraint(equalTo: innerView.topAnchor),
            deliveryLabel.bottomAnchor.constraint(equalTo: innerView.bottomAnchor),
            deliveryLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
            deliveryLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),

            // Rating view
            ratingView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12),
            ratingView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            ratingView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            hStack.topAnchor.constraint(equalTo: ratingView.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: -12),

            // Run button
            runButton.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 12),
            runButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            runButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            runButton.heightAnchor.constraint(equalToConstant: 48),

            // Log
            logTextView.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 12),
            logTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            logTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 60)
        ])
    }
}

// MARK: - Actions

private extension ViewController {

    @objc func runTapped() {
        let bot = TradingBot()
        logTextView.text = bot.run()
        logTextView.isHidden = false
        emptyLabel.isHidden = true
    }
}
