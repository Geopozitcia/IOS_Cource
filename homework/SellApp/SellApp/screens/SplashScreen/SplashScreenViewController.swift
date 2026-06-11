import UIKit

final class SplashScreenViewController: UIViewController {

    private enum Constants {
        static let splashDuration: TimeInterval = 3.0
        static let fadeOutDuration: TimeInterval = 0.8
        static let pulseMinAlpha: CGFloat = 0.5
        static let pulseDuration: TimeInterval = 0.8
        static let imageSize: CGFloat = 380
        static let indicatorBottomOffset: CGFloat = -60
    }

    private let imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    var onFinished: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSubviews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        startAnimations()
    }
}

// MARK: - Setup

private extension SplashScreenViewController {

    func setupBackground() {
        view.backgroundColor = .black
    }

    func setupSubviews() {
        view.addSubview(imageView)
        view.addSubview(activityIndicator)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.indicatorBottomOffset)
        ])
    }
}

// MARK: - Animations

private extension SplashScreenViewController {

    func startAnimations() {
        startPulseAnimation()
        scheduleTransition()
    }

    func startPulseAnimation() {
        UIView.animate(
            withDuration: Constants.pulseDuration,
            delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.imageView.alpha = Constants.pulseMinAlpha
            }
        )
    }

    func scheduleTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.splashDuration) {
            self.transitionToMain()
        }
    }

    func transitionToMain() {
        UIView.animate(
            withDuration: Constants.fadeOutDuration,
            animations: {
                self.view.alpha = 0
            },
            completion: { _ in
                self.onFinished?()
            }
        )
    }
}
