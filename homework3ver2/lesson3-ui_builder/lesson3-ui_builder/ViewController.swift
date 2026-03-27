import UIKit

class ViewController: UIViewController {

    private var logTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        let screenWidth = view.bounds.width
        var currentY = view.safeAreaInsets.top + 16

        // ImageView
        let imageView = UIImageView(frame: CGRect(x: 0, y: currentY - 16, width: screenWidth, height: 200))
        imageView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        imageView.contentMode = .center
        let placeholderLabel = UILabel(frame: imageView.bounds)
        placeholderLabel.text = "UIImageView"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .systemGray
        placeholderLabel.font = .systemFont(ofSize: 16)
        imageView.addSubview(placeholderLabel)
        view.addSubview(imageView)
        currentY = imageView.frame.maxY + 16

        // название
        let nameLabel = UILabel(frame: CGRect(x: 16, y: currentY, width: screenWidth - 32, height: 48))
        nameLabel.text = "Some Product for sale, Type A, Black"
        nameLabel.numberOfLines = 2
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = .white
        view.addSubview(nameLabel)
        currentY = nameLabel.frame.maxY + 8

        // новая цена
        let priceLabel = UILabel(frame: CGRect(x: 16, y: currentY, width: 130, height: 30))
        priceLabel.text = "12 990 $"
        priceLabel.font = .systemFont(ofSize: 22, weight: .bold)
        priceLabel.textColor = .white
        view.addSubview(priceLabel)

        // старая цена
        let oldPriceLabel = UILabel(frame: CGRect(x: priceLabel.frame.maxX + 8, y: currentY, width: 100, height: 30))
        let strikeAttr = NSAttributedString(string: "19 990 $", attributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemGray
        ])
        oldPriceLabel.attributedText = strikeAttr
        oldPriceLabel.font = .systemFont(ofSize: 15)
        view.addSubview(oldPriceLabel)
        currentY += 38

        let containerView = UIView(frame: CGRect(x: 16, y: currentY, width: screenWidth - 32, height: 56))
        containerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        containerView.layer.cornerRadius = 10

        let innerView = UIView(frame: CGRect(x: 8, y: 8, width: containerView.bounds.width - 16, height: 40))
        innerView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
        innerView.layer.cornerRadius = 8
        let deliveryLabel = UILabel(frame: innerView.bounds)
        deliveryLabel.text = "Delivery: tomorrow"
        deliveryLabel.textAlignment = .center
        deliveryLabel.font = .systemFont(ofSize: 14)
        deliveryLabel.textColor = .white
        innerView.addSubview(deliveryLabel)
        containerView.addSubview(innerView)
        view.addSubview(containerView)
        currentY = containerView.frame.maxY + 12

        let ratingView = UIView()
        ratingView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        ratingView.layer.cornerRadius = 10
        ratingView.layer.borderWidth = 1
        ratingView.layer.borderColor = UIColor.systemGray.cgColor

        let ratingLabel = UILabel()
        ratingLabel.text = "4.4 ★"
        ratingLabel.font = .systemFont(ofSize: 15, weight: .medium)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center

        let reviewsLabel = UILabel()
        reviewsLabel.text = "1513 reviews"
        reviewsLabel.font = .systemFont(ofSize: 15, weight: .medium)
        reviewsLabel.textColor = .white
        reviewsLabel.textAlignment = .center

        let hStack = UIStackView(arrangedSubviews: [ratingLabel, reviewsLabel])
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 8
        hStack.translatesAutoresizingMaskIntoConstraints = false

        ratingView.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: ratingView.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: -12)
        ])

        ratingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingView)
        NSLayoutConstraint.activate([
            ratingView.topAnchor.constraint(equalTo: view.topAnchor, constant: currentY),
            ratingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ratingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // UIButton — Run
        let runButton = UIButton(type: .system)
        runButton.setTitle("Run command", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = 12
        runButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        runButton.addTarget(self, action: #selector(runTapped), for: .touchUpInside)

        //лог бота
        logTextView = UITextView()
        logTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        logTextView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        logTextView.layer.cornerRadius = 10
        logTextView.isEditable = false
        logTextView.text = "Press Run to start the bot..."
        logTextView.textColor = .systemGray

        let vStack = UIStackView(arrangedSubviews: [runButton, logTextView])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vStack)

        NSLayoutConstraint.activate([
            runButton.heightAnchor.constraint(equalToConstant: 48),
            logTextView.heightAnchor.constraint(equalToConstant: 160),
            vStack.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func runTapped() {
        let bot = TradingBot()
        logTextView.text = bot.run()
        logTextView.textColor = .white
    }
}

// по какой то причине у меня в симуляторе не отображается SE и в принципе нет айфонов с кнопкой. Не могу проверить как там работает :(
