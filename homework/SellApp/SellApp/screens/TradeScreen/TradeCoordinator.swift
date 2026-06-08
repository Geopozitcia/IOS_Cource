import UIKit

final class TradeCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let wallet: Wallet
    private let chartVC = ChartViewController()

    init(navigationController: UINavigationController, wallet: Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet
    }

    func start() {
        let viewModel = TradeViewModel(wallet: wallet)
        let vc = TradeViewController(viewModel: viewModel, coordinator: self)
        viewModel.coordinator = self
        vc.title = "Trading"  // добавь эту строку
        navigationController.setViewControllers([vc], animated: false)
    }

    func showChart() {
        navigationController.pushViewController(chartVC, animated: true)
    }

    func loadChart() {
        chartVC.loadCandles()
    }

    func resetChart() {
        chartVC.resetCandles()
    }

    func showWallet() {
        let walletVC = WalletViewController(wallet: wallet)
        navigationController.present(walletVC, animated: true)
    }

    func showCurrencyPicker(from: String, to: String, delegate: CurrencyViewControllerDelegate) {
        let quickVC = QuickCurrencyViewController()
        quickVC.setInitialPair(from: from, to: to)
        quickVC.delegate = delegate
        let nav = UINavigationController(rootViewController: quickVC)
        navigationController.present(nav, animated: true)
    }
}
