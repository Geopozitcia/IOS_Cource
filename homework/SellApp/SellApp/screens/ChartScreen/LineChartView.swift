import UIKit

final class LineChartView: UIView {

    private enum Constants {
        static let lineWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
        static let shadowOpacity: Float = 0.3
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let dotRadius: CGFloat = 6
        static let gridLineWidth: CGFloat = 0.5
        static let gridLabelFontSize: CGFloat = 10
        static let gridLabelWidth: CGFloat = 44
        static let gridLabelHeight: CGFloat = 16
        static let chartPaddingLeft: CGFloat = 48
        static let chartPaddingRight: CGFloat = 8
        static let chartPaddingTop: CGFloat = 8
        static let chartPaddingBottom: CGFloat = 24
        static let gridStepsCount: Int = 5
        static let selectedDotRadius: CGFloat = 8
        static let priceTagWidth: CGFloat = 60
        static let priceTagHeight: CGFloat = 24
        static let priceTagCornerRadius: CGFloat = 6
        static let priceTagFontSize: CGFloat = 11
    }

    private let lineLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()
    private let dotLayer = CAShapeLayer()
    private let selectedDotLayer = CAShapeLayer()

    private var prices: [Double] = []
    private var selectedIndex: Int? = nil

    private let priceTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.priceTagFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.systemBlue
        label.layer.cornerRadius = Constants.priceTagCornerRadius
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var priceTagCenterX: NSLayoutConstraint?
    private var priceTagCenterY: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupLayers()
        setupGesture()
        setupPriceTag()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }

    func configure(with prices: [Double]) {
        self.prices = prices
        selectedIndex = nil
        priceTagLabel.isHidden = true
        redraw()
    }
}

// MARK: - Setup

private extension LineChartView {

    func setupAppearance() {
        backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = false
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius
    }

    func setupLayers() {
        fillLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        fillLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(fillLayer)

        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.lineWidth = Constants.lineWidth
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        layer.addSublayer(lineLayer)

        gridLayer.fillColor = UIColor.clear.cgColor
        gridLayer.strokeColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        gridLayer.lineWidth = Constants.gridLineWidth
        layer.addSublayer(gridLayer)

        dotLayer.fillColor = UIColor.systemBlue.cgColor
        dotLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(dotLayer)

        selectedDotLayer.fillColor = UIColor.white.cgColor
        selectedDotLayer.strokeColor = UIColor.systemBlue.cgColor
        selectedDotLayer.lineWidth = 2
        layer.addSublayer(selectedDotLayer)
    }

    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    func setupPriceTag() {
        addSubview(priceTagLabel)

        priceTagCenterX = priceTagLabel.centerXAnchor.constraint(equalTo: leadingAnchor)
        priceTagCenterY = priceTagLabel.centerYAnchor.constraint(equalTo: topAnchor)

        NSLayoutConstraint.activate([
            priceTagLabel.widthAnchor.constraint(equalToConstant: Constants.priceTagWidth),
            priceTagLabel.heightAnchor.constraint(equalToConstant: Constants.priceTagHeight),
            priceTagCenterX!,
            priceTagCenterY!
        ])
    }
}

// MARK: - Drawing

private extension LineChartView {

    var chartRect: CGRect {
        return CGRect(
            x: Constants.chartPaddingLeft,
            y: Constants.chartPaddingTop,
            width: bounds.width - Constants.chartPaddingLeft - Constants.chartPaddingRight,
            height: bounds.height - Constants.chartPaddingTop - Constants.chartPaddingBottom
        )
    }

    func redraw() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        drawGrid()
        drawChart()
        drawDots()
        drawSelectedDot()
    }

    func pointX(at index: Int) -> CGFloat {
        guard prices.count > 1 else { return chartRect.minX }
        let step = chartRect.width / CGFloat(prices.count - 1)
        return chartRect.minX + CGFloat(index) * step
    }

    func pointY(for price: Double, min: Double, max: Double) -> CGFloat {
        guard max != min else { return chartRect.midY }
        let normalized = (price - min) / (max - min)
        return chartRect.maxY - CGFloat(normalized) * chartRect.height
    }

    func drawGrid() {
        guard !prices.isEmpty else {
            gridLayer.path = nil
            clearGridLabels()
            return
        }

        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0
        let path = UIBezierPath()

        clearGridLabels()

        for i in 0..<Constants.gridStepsCount {
            let fraction = CGFloat(i) / CGFloat(Constants.gridStepsCount - 1)
            let y = chartRect.maxY - fraction * chartRect.height
            path.move(to: CGPoint(x: chartRect.minX, y: y))
            path.addLine(to: CGPoint(x: chartRect.maxX, y: y))

            let priceValue = minPrice + Double(fraction) * (maxPrice - minPrice)
            addGridLabel(text: formatPrice(priceValue), x: 0, y: y)
        }

        let timeStep = chartRect.width / CGFloat(Swift.max(prices.count - 1, 1))
        for i in 0..<prices.count {
            guard i == 0 || i == prices.count - 1 || i % 5 == 0 else { continue }
            let x = chartRect.minX + CGFloat(i) * timeStep
            path.move(to: CGPoint(x: x, y: chartRect.minY))
            path.addLine(to: CGPoint(x: x, y: chartRect.maxY))
            addTimeLabel(text: "\(i + 1)", x: x, y: chartRect.maxY + 4)
        }

        gridLayer.path = path.cgPath
    }

    func drawChart() {
        guard prices.count > 1 else {
            lineLayer.path = nil
            fillLayer.path = nil
            return
        }

        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0

        let linePath = UIBezierPath()
        let fillPath = UIBezierPath()

        let firstX = pointX(at: 0)
        let firstY = pointY(for: prices[0], min: minPrice, max: maxPrice)

        linePath.move(to: CGPoint(x: firstX, y: firstY))
        fillPath.move(to: CGPoint(x: firstX, y: chartRect.maxY))
        fillPath.addLine(to: CGPoint(x: firstX, y: firstY))

        for i in 1..<prices.count {
            let x = pointX(at: i)
            let y = pointY(for: prices[i], min: minPrice, max: maxPrice)
            linePath.addLine(to: CGPoint(x: x, y: y))
            fillPath.addLine(to: CGPoint(x: x, y: y))
        }

        let lastX = pointX(at: prices.count - 1)
        fillPath.addLine(to: CGPoint(x: lastX, y: chartRect.maxY))
        fillPath.close()

        lineLayer.path = linePath.cgPath
        fillLayer.path = fillPath.cgPath
    }

    func drawDots() {
        guard !prices.isEmpty else {
            dotLayer.path = nil
            return
        }

        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0
        let dotsPath = UIBezierPath()

        for i in 0..<prices.count {
            let x = pointX(at: i)
            let y = pointY(for: prices[i], min: minPrice, max: maxPrice)
            let rect = CGRect(
                x: x - Constants.dotRadius / 2,
                y: y - Constants.dotRadius / 2,
                width: Constants.dotRadius,
                height: Constants.dotRadius
            )
            dotsPath.append(UIBezierPath(ovalIn: rect))
        }

        dotLayer.path = dotsPath.cgPath
    }

    func drawSelectedDot() {
        guard let index = selectedIndex, !prices.isEmpty else {
            selectedDotLayer.path = nil
            return
        }

        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0
        let x = pointX(at: index)
        let y = pointY(for: prices[index], min: minPrice, max: maxPrice)

        let rect = CGRect(
            x: x - Constants.selectedDotRadius,
            y: y - Constants.selectedDotRadius,
            width: Constants.selectedDotRadius * 2,
            height: Constants.selectedDotRadius * 2
        )
        selectedDotLayer.path = UIBezierPath(ovalIn: rect).cgPath

        priceTagLabel.text = formatPrice(prices[index])
        priceTagLabel.isHidden = false

        let tagX = Swift.min(Swift.max(x, Constants.priceTagWidth / 2), bounds.width - Constants.priceTagWidth / 2)
        let tagY = Swift.max(y - Constants.selectedDotRadius - Constants.priceTagHeight, Constants.priceTagHeight / 2)

        priceTagCenterX?.constant = tagX
        priceTagCenterY?.constant = tagY
    }

    func addGridLabel(text: String, x: CGFloat, y: CGFloat) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: Constants.gridLabelFontSize)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.frame = CGRect(
            x: x,
            y: y - Constants.gridLabelHeight / 2,
            width: Constants.gridLabelWidth - 4,
            height: Constants.gridLabelHeight
        )
        addSubview(label)
    }

    func addTimeLabel(text: String, x: CGFloat, y: CGFloat) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: Constants.gridLabelFontSize)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.frame = CGRect(
            x: x - Constants.gridLabelWidth / 2,
            y: y,
            width: Constants.gridLabelWidth,
            height: Constants.gridLabelHeight
        )
        addSubview(label)
    }

    func clearGridLabels() {
        subviews.filter { $0 is UILabel && $0 !== priceTagLabel }.forEach { $0.removeFromSuperview() }
    }

    func formatPrice(_ price: Double) -> String {
        return String(format: "%.1f", price)
    }
}

// MARK: - Gestures

private extension LineChartView {

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !prices.isEmpty, prices.count > 1 else { return }

        let location = gesture.location(in: self)
        let step = chartRect.width / CGFloat(prices.count - 1)
        let rawIndex = (location.x - chartRect.minX) / step
        let index = Swift.max(0, Swift.min(Int(rawIndex.rounded()), prices.count - 1))

        selectedIndex = index
        drawSelectedDot()
    }
}
