import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let sharedWallet = Wallet(currencies: ["USD", "EUR", "BTC", "ETH", "RUB"])

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        setupNavigationBarAppearance()
        window = UIWindow(windowScene: windowScene)
        if AuthService.shared.isAutoLoginEnabled && AuthService.shared.isLoggedIn {
            showSplash()
        } else {
            showAuth()
        }
        
        window?.makeKeyAndVisible()
    }

    func showAuth() {
        let authVC = AuthViewController()
        authVC.onSuccess = { [weak self] in
            self?.showSplash()
        }
        window?.rootViewController = authVC
    }

    func showSplash() {
        let splash = SplashScreenViewController()
        splash.onFinished = { [weak self] in
            self?.window?.rootViewController = self?.makeRootController()
        }
        window?.rootViewController = splash
    }
}

private extension SceneDelegate {

    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }

    func makeRootController() -> UIViewController {
        let tabBar = UITabBarController()
        tabBar.viewControllers = [
            makeTradeTab(),
            makeCurrencyTab(),
            makeP2PTab(),
            makeSettingsTab()
        ]
        return tabBar
    }
    
    func makeSettingsTab() -> UIViewController {
        let settingsVC = SettingsViewController()
        settingsVC.onLogout = { [weak self] in
            self?.showAuth()
        }
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        return settingsVC
    }
    

    func makeTradeTab() -> UIViewController {
        let nav = UINavigationController()
        let coordinator = TradeCoordinator(navigationController: nav, wallet: sharedWallet)
        coordinator.start()
        nav.tabBarItem = UITabBarItem(
            title: "Trade",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        )
        nav.topViewController?.title = "Trading"
        return nav
    }

    func makeCurrencyTab() -> UIViewController {
        let currencyVC = CurrencyViewController()
        currencyVC.title = "Currencies"
        currencyVC.tabBarItem = UITabBarItem(
            title: "Currencies",
            image: UIImage(systemName: "dollarsign.circle"),
            selectedImage: UIImage(systemName: "dollarsign.circle.fill")
        )
        return currencyVC
    }

    func makeP2PTab() -> UIViewController {
        let nav = UINavigationController()
        let coordinator = P2PCoordinator(navigationController: nav, wallet: sharedWallet)
        coordinator.start()
        nav.tabBarItem = UITabBarItem(
            title: "P2P",
            image: UIImage(systemName: "arrow.left.arrow.right.circle"),
            selectedImage: UIImage(systemName: "arrow.left.arrow.right.circle.fill")
        )
        return nav
    }
}
