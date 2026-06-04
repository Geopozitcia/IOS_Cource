import SwiftUI
import UIKit

struct TopicSelectorRepresentable: UIViewRepresentable {

    @Binding var selectedTopics: [FeedbackTopic]

    func makeUIView(context: Context) -> TopicSelectorView {
        let view = TopicSelectorView()
        view.delegate = context.coordinator
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: TopicSelectorView, context: Context) {
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedTopics: $selectedTopics)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: TopicSelectorView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width
        let size = uiView.intrinsicContentSize
        return CGSize(width: width, height: size.height)
    }

    final class Coordinator: NSObject, TopicSelectorViewDelegate {
        private var selectedTopics: Binding<[FeedbackTopic]>

        init(selectedTopics: Binding<[FeedbackTopic]>) {
            self.selectedTopics = selectedTopics
        }

        func topicSelectorView(_ view: TopicSelectorView, didUpdateSelectedTopics topics: [FeedbackTopic]) {
            selectedTopics.wrappedValue = topics
        }
    }
}
