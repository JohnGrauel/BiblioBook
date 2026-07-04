import SwiftUI

/// In-app help describing every feature of BiblioBook.
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Getting Started") {
                    HelpTopicView(
                        symbol: "plus.circle",
                        title: "Adding Books",
                        text: "Tap the + button in the book list to add a new book. Only a title is required to save - everything else can be filled in later."
                    )
                    HelpTopicView(
                        symbol: "wand.and.stars",
                        title: "Sample Books",
                        text: "Want to explore first? Open Utilities from the toolbar menu and generate up to 20 realistic sample books."
                    )
                }

                Section("Browsing & Editing") {
                    HelpTopicView(
                        symbol: "sidebar.left",
                        title: "The Book List",
                        text: "Books appear in the sidebar sorted by title. Select one to view and edit it in the detail pane. Swipe left on a row to delete a book."
                    )
                    HelpTopicView(
                        symbol: "textformat.abc",
                        title: "Jump by Letter",
                        text: "Use the alphanumeric index along the right edge of the list to jump straight to the first title starting with that letter. Titles that start with a number or symbol group under #."
                    )
                    HelpTopicView(
                        symbol: "square.and.pencil",
                        title: "Editing Details",
                        text: "The detail view is directly editable - just tap any field and type. Changes save automatically. Use the stars to rate a book, and the toggles to record acquisition and lending dates."
                    )
                }

                Section("Photos") {
                    HelpTopicView(
                        symbol: "camera",
                        title: "Cover & Photos",
                        text: "Each book can store a cover image plus four photos, taken with the camera or chosen from your photo library. Images are automatically compressed to at most 200 KB."
                    )
                    HelpTopicView(
                        symbol: "rotate.right",
                        title: "Rotating Photos",
                        text: "The four photos can each be rotated in 90 degree steps using the Rotate button beneath the image."
                    )
                }

                Section("Lending") {
                    HelpTopicView(
                        symbol: "person.crop.circle.badge.clock",
                        title: "Tracking Loans",
                        text: "Record who you lent a book to along with the lent and return dates. Books that are out on loan show an orange indicator in the list."
                    )
                }

                Section("Backup") {
                    HelpTopicView(
                        symbol: "square.and.arrow.up.on.square",
                        title: "Export & Import",
                        text: "Open Import & Export from the toolbar menu to save your whole library as a JSON file - to iCloud Drive or anywhere in the Files app - and to bring books back in later. Duplicate books are detected by checksum and skipped on import."
                    )
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// One help entry: an SF Symbol, a heading, and explanatory text.
struct HelpTopicView: View {
    let symbol: String
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
