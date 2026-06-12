import UIKit
import SwiftUI

@available(iOS 17.0, *)
final class FeedbackViewController: UIHostingController<FeedbackView> {

    init() {
        super.init(rootView: FeedbackView())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Обратная связь"
    }
}
