import UIKit

final class CurrencyViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let headerHeight: CGFloat = 160
        static let cellSize: CGFloat = 72
        static let cellSpacing: CGFloat = 8
    }

    private let viewModel = CurrencyViewModel()

    private let fromButton = UIButton(type: .system)
    private let toButton = UIButton(type: .system)
    private let arrowLabel = UILabel()
    private let rateLabel = UILabel()
    private let timerLabel = UILabel()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Constants.cellSize, height: Constants.cellSize)
        layout.minimumInteritemSpacing = Constants.cellSpacing
        layout.minimumLineSpacing = Constants.cellSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Constants.padding,
            left: Constants.padding,
            bottom: Constants.padding,
            right: Constants.padding
        )
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        setupSubviews()
        setupConstraints()
        setupViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
    }
}

// MARK: - Setup

private extension CurrencyViewController {

    func setupSubviews() {
        fromButton.setTitle("USD", for: .normal)
        fromButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        fromButton.setTitleColor(.white, for: .normal)
        fromButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        fromButton.layer.cornerRadius = 10
        fromButton.addTarget(self, action: #selector(fromTapped), for: .touchUpInside)
        fromButton.translatesAutoresizingMaskIntoConstraints = false

        arrowLabel.text = "->"
        arrowLabel.textColor = .systemGray
        arrowLabel.font = .systemFont(ofSize: 22)
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false

        toButton.setTitle("BTC", for: .normal)
        toButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        toButton.setTitleColor(.white, for: .normal)
        toButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        toButton.layer.cornerRadius = 10
        toButton.addTarget(self, action: #selector(toTapped), for: .touchUpInside)
        toButton.translatesAutoresizingMaskIntoConstraints = false

        rateLabel.text = "Rate: ..."
        rateLabel.textColor = .systemGray
        rateLabel.font = .systemFont(ofSize: 14)
        rateLabel.textAlignment = .center
        rateLabel.translatesAutoresizingMaskIntoConstraints = false

        timerLabel.text = "Update in: 5s"
        timerLabel.textColor = .systemGray
        timerLabel.font = .systemFont(ofSize: 13)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        collectionView.backgroundColor = .clear
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fromButton)
        view.addSubview(arrowLabel)
        view.addSubview(toButton)
        view.addSubview(rateLabel)
        view.addSubview(timerLabel)
        view.addSubview(collectionView)
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            fromButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            fromButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            fromButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            fromButton.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.35),

            arrowLabel.centerYAnchor.constraint(equalTo: fromButton.centerYAnchor),
            arrowLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            toButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.padding),
            toButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),
            toButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            toButton.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.35),

            rateLabel.topAnchor.constraint(equalTo: fromButton.bottomAnchor, constant: 10),
            rateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            rateLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            timerLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 4),
            timerLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.padding),
            timerLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.padding),

            collectionView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: Constants.padding),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    func setupViewModel() {
        viewModel.onUpdate = {
            self.updateUI()
        }
        viewModel.start()
        updateUI()
    }

    func updateUI() {
        fromButton.setTitle(viewModel.fromCurrency, for: .normal)
        toButton.setTitle(viewModel.toCurrency, for: .normal)
        rateLabel.text = "Rate: \(viewModel.rateText)"
        timerLabel.text = "Update in: \(viewModel.secondsUntilRefresh)s"

        if viewModel.selectedSlot == 0 {
            fromButton.layer.borderWidth = 2
            fromButton.layer.borderColor = UIColor.systemBlue.cgColor
            toButton.layer.borderWidth = 0
        } else {
            toButton.layer.borderWidth = 2
            toButton.layer.borderColor = UIColor.systemBlue.cgColor
            fromButton.layer.borderWidth = 0
        }

        collectionView.reloadData()
    }
}

// MARK: - Actions

private extension CurrencyViewController {

    @objc func fromTapped() {
        viewModel.selectSlot(0)
    }

    @objc func toTapped() {
        viewModel.selectSlot(1)
    }
}

// MARK: - UICollectionViewDataSource

extension CurrencyViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currencies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.reuseId, for: indexPath) as! CurrencyCell
        let currency = viewModel.currencies[indexPath.item]
        cell.configure(with: currency, isDisabled: viewModel.isDisabled(currency))
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CurrencyViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = viewModel.currencies[indexPath.item]
        guard !viewModel.isDisabled(currency) else { return }
        viewModel.selectCurrency(currency)
    }
}
