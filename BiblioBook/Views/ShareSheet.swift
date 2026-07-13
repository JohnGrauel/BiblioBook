import SwiftUI

/// A thin SwiftUI wrapper around `UIActivityViewController` for presenting the
/// system share sheet (Mail, Messages, AirDrop, Save to Files, …). Used to send
/// a book as a `.bibliobook` file attachment.
struct ShareSheet: UIViewControllerRepresentable {
    /// The items to share — for BiblioBook, a single `.bibliobook` file URL.
    let items: [URL]

    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
