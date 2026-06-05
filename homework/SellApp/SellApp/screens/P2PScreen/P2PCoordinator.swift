import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

final class P2PCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let wallet: Wallet

    init(navigationController: UINavigationController, wallet: Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet
    }

    func start() {
        let viewModel = P2PViewModel(wallet: wallet)
        let vc = P2PViewController(viewModel: viewModel, coordinator: self)
        viewModel.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showSellerInfo(_ offer: P2POffer) {
        let vc = SellerInfoViewController(offer: offer)
        navigationController.pushViewController(vc, animated: true)
    }

    func showExchangeAlert(
        offer: P2POffer,
        fromCurrency: String,
        onConfirm: @escaping (Double) -> Void
    ) {
        let alert = UIAlertController(
            title: offer.sellerName,
            message: "Rate: \(String(format: "%.4f", offer.rate))\nEnter amount in \(fromCurrency)",
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.keyboardType = .decimalPad
            field.placeholder = "Amount"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Exchange", style: .default) { _ in
            guard let text = alert.textFields?.first?.text,
                  let amount = Double(text) else { return }
            onConfirm(amount)
        })
        navigationController.present(alert, animated: true)
    }

    func showResult(success: Bool, message: String) {
        let alert = UIAlertController(
            title: success ? "Success" : "Exchange Failed",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }

    func showWallet() {
        let walletVC = WalletViewController(wallet: wallet)
        navigationController.present(walletVC, animated: true)
    }

    func showCurrencyPicker(from: String, to: String, delegate: CurrencyViewControllerDelegate) {
        let currencyVC = CurrencyViewController()
        currencyVC.setInitialPair(from: from, to: to)
        currencyVC.delegate = delegate
        currencyVC.mode = .apiOnly
        let nav = UINavigationController(rootViewController: currencyVC)
        navigationController.present(nav, animated: true)
    }
}
