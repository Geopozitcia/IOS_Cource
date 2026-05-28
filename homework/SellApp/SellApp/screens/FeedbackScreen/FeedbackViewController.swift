import UIKit
import SwiftUI

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
