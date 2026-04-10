import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeRootController()
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {

    func makeRootController() -> UIViewController {
        let tabBar = UITabBarController() // gets both tabs via viewControllers
        tabBar.viewControllers = [makeTradeTab(), makeCurrencyTab()]
        return tabBar
    }

    func makeTradeTab() -> UIViewController { // shelling ViewController in UINavigationController
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
