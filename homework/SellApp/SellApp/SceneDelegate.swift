import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        setupNavigationBarAppearance()

        window = UIWindow(windowScene: windowScene)
        let splash = SplashScreenViewController()
        splash.onFinished = { [weak self] in
            self?.window?.rootViewController = self?.makeRootController()
        }
        window?.rootViewController = splash
        window?.makeKeyAndVisible()
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
        tabBar.viewControllers = [makeTradeTab(), makeCurrencyTab()]
        return tabBar
    }

    func makeTradeTab() -> UIViewController {
        let tradeVC = ViewController()
        let nav = UINavigationController(rootViewController: tradeVC)
        tradeVC.title = "Trading"
        nav.tabBarItem = UITabBarItem(
            title: "Trade",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        )
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
}
