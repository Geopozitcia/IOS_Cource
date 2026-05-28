import UIKit
import SwiftUI

final class HeatmapViewController: UIHostingController<HeatmapView> {

    init() {
        super.init(rootView: HeatmapView())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Heatmap"
    }
}
