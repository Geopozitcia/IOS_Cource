import UIKit

final class LineChartView: UIView {

    private let lineLayer = CAShapeLayer() // CAShapeLayer для графика
    private let gridLayer = CAShapeLayer() // CAShapeLayer для его сетки
    private let selectionLayer = CAShapeLayer() // CAShapeLayer для точки
    private let valueLabel = UILabel() // значение цены в выбранной точке
    private var values: [Double] = []
    private var selectedIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(gridLayer) // сетка будет ниже графика
        self.layer.addSublayer(lineLayer) // добавляем слой для рисования на view.
        self.layer.addSublayer(selectionLayer) // точка находится выше всех в иеерархии
        self.addSubview(valueLabel)
        valueLabel.clipsToBounds = true
        valueLabel.layer.cornerRadius = 6
        valueLabel.textColor = .white
        valueLabel.backgroundColor = .systemGray
        valueLabel.textAlignment = .center
        valueLabel.isHidden = true
        setupGestures()
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with values: [Double]) {
        self.values = values
        lineLayer.fillColor = nil
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.lineWidth = 2
        
        gridLayer.fillColor = nil
        gridLayer.strokeColor = UIColor.systemGray.cgColor
        gridLayer.lineWidth = 0.5
        gridLayer.opacity = 0.7
        
        selectionLayer.fillColor = UIColor.white.cgColor
        selectionLayer.strokeColor = UIColor.systemBlue.cgColor
        selectionLayer.lineWidth = 2
        
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        gridLayer.frame = bounds
        selectionLayer.frame = bounds
        lineLayer.path = buildLinePath().cgPath
        gridLayer.path = buildGridPath().cgPath
        selectionLayer.path = buildSelectedPoint().cgPath

    }
    
    private func buildLinePath() -> UIBezierPath {
        let path = UIBezierPath()
        guard values.count > 1 else { return path }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0
        for i in 0..<values.count {
            let xCoordinate = (bounds.width / CGFloat(values.count - 1)) * CGFloat(i)
            let normalized = (values[i] - minValue) / (maxValue - minValue)
            let yCoordinate = CGFloat((1 - normalized) * bounds.height)
            let point = CGPoint(x: xCoordinate, y: yCoordinate)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        return path
    }
    
    private func buildGridPath() -> UIBezierPath {
        let path = UIBezierPath()

        // horizontal
        for i in 0..<5 {
            let normalized = CGFloat(i) / 4
            let yCoordinate = (1 - normalized) * bounds.height
            let yPoint = CGPoint(x: 0, y: yCoordinate)
            let xPoint = CGPoint(x: bounds.width, y: yCoordinate)
            path.move(to: yPoint)
            path.addLine(to: xPoint)
        }
        // vertical
        for j in 0..<5 {
            let xCoordinate = (bounds.width / 4) * CGFloat(j)
            path.move(to: CGPoint(x: xCoordinate, y: 0))
            path.addLine(to: CGPoint(x: xCoordinate, y: bounds.height))
        }
        
        return path
    }
    
    private func buildSelectedPoint() -> UIBezierPath {
        let path = UIBezierPath()

        guard let index = selectedIndex, values.count > 1 else {
            return path
        }

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0

        guard maxValue != minValue else {
            return path
        }

        let xCoordinate = (bounds.width / CGFloat(values.count - 1)) * CGFloat(index)

        let normalized = (values[index] - minValue) / (maxValue - minValue)
        let yCoordinate = CGFloat((1 - normalized) * bounds.height)

        let radius: CGFloat = 5

        let rect = CGRect(
            x: xCoordinate - radius,
            y: yCoordinate - radius,
            width: radius * 2,
            height: radius * 2
        )

        return UIBezierPath(ovalIn: rect)
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard values.count > 1 else { return }

        let xTapLocation = gesture.location(in: self).x
        let rawIndex = (xTapLocation * CGFloat(values.count - 1)) / bounds.width
        let index = Int(rawIndex.rounded())
        let clampedIndex = max(0, min(index, values.count - 1))

        selectedIndex = clampedIndex

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0
        guard maxValue != minValue else { return }

        let x = (bounds.width / CGFloat(values.count - 1)) * CGFloat(clampedIndex)

        let normalized = (values[clampedIndex] - minValue) / (maxValue - minValue)
        let y = CGFloat((1 - normalized) * bounds.height)

        // selection label
        valueLabel.text = String(format: "%.2f", values[clampedIndex])
        valueLabel.sizeToFit()

        let padding: CGFloat = 8
        let labelWidth = valueLabel.bounds.width + padding * 2
        let labelHeight = valueLabel.bounds.height + 4

        valueLabel.frame = CGRect(
            x: x - labelWidth / 2,
            y: y - labelHeight - 10,
            width: labelWidth,
            height: labelHeight
        )

        valueLabel.isHidden = false

        // кружок
        let radius: CGFloat = 5
        let rect = CGRect(
            x: x - radius,
            y: y - radius,
            width: radius * 2,
            height: radius * 2
        )

        selectionLayer.path = UIBezierPath(ovalIn: rect).cgPath
    }

}



    

