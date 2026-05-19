import UIKit

final class CandleView: UIView {

    private enum Constants {
        static let bodyWidth: CGFloat = 30
        static let wickWidth: CGFloat = 3
        static let minBodyHeight: CGFloat = 10
        static let maxBodyHeight: CGFloat = 80
        static let minWickHeight: CGFloat = 20
        static let maxWickHeight: CGFloat = 120
        static let totalHeight: CGFloat = 160
        static let totalWidth: CGFloat = 50
    }

    var onTap: ((CandleModel) -> Void)?
    var onLongPress: ((CandleModel) -> Void)?

    private let wickView = UIView()
    private let bodyView = UIView()
    private var model: CandleModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with model: CandleModel) {
        self.model = model

        let color: UIColor = model.isBullish ? .systemGreen : .systemRed

        let rawBody = CGFloat(model.bodyHeight)
        let bodyHeight = Swift.max(Constants.minBodyHeight, Swift.min(rawBody, Constants.maxBodyHeight))

        let rawWick = CGFloat(model.wickHeight)
        let wickHeight = Swift.max(Constants.minWickHeight, Swift.min(rawWick, Constants.maxWickHeight))

        let bodyY = (Constants.totalHeight - bodyHeight) / 2
        let wickY = (Constants.totalHeight - wickHeight) / 2
        let wickX = (Constants.totalWidth - Constants.wickWidth) / 2
        let bodyX = (Constants.totalWidth - Constants.bodyWidth) / 2

        wickView.frame = CGRect(x: wickX, y: wickY, width: Constants.wickWidth, height: wickHeight)
        bodyView.frame = CGRect(x: bodyX, y: bodyY, width: Constants.bodyWidth, height: bodyHeight)

        wickView.backgroundColor = color
        bodyView.backgroundColor = color
    }
}

private extension CandleView {

    func setupSubviews() {
        addSubview(wickView)
        addSubview(bodyView)
        wickView.layer.cornerRadius = Constants.wickWidth / 2
        bodyView.layer.cornerRadius = 4
    }

    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(tap)
        addGestureRecognizer(longPress)
    }

    @objc func handleTap() {
        guard let model = model else { return }
        onTap?(model)
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let model = model else { return }
        onLongPress?(model)
    }
}
