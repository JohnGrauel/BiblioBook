import SwiftUI
import SwiftData

/// The root split view: the book list in the sidebar, details on the right.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedBook: Book? = nil

    @Query private var books: [Book]

    /// Drives the alert shown after a shared book is opened from Mail, etc.
    private struct ImportResult: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    @State private var importResult: ImportResult? = nil

    var body: some View {
        NavigationSplitView {
            BookListView(selection: $selectedBook)
                .safeAreaInset(edge: .bottom) {
                    Text("Book Count: \(books.count)")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .glassEffect(in: .rect)
                }//status footer
        } detail: {
            if let selectedBook {
                BookDetailView(book: selectedBook)
            } else {
                ContentUnavailableView(
                    "Select a Book",
                    systemImage: "book.closed",
                    description: Text("Choose a book from the list, or tap the + button to add one.")
                )
            }
        }//nav
        .onOpenURL { url in
            handleIncoming(url)
        }
        .alert(item: $importResult) { result in
            Alert(title: Text(result.title), message: Text(result.message), dismissButton: .default(Text("OK")))
        }
    }//body

    /// Imports a `.bibliobook` file that was tapped in Mail (or opened into the
    /// app from anywhere), then selects the newly added book.
    private func handleIncoming(_ url: URL) {
        guard url.pathExtension.lowercased() == "bibliobook" else { return }

        switch BookSharing.importBook(from: url, into: modelContext) {
        case .imported(let book):
            selectedBook = book
            importResult = ImportResult(
                title: "Book Added",
                message: "“\(book.title.isEmpty ? "Untitled" : book.title)” was added to your library."
            )
        case .duplicate(let title):
            importResult = ImportResult(
                title: "Already in Your Library",
                message: "“\(title.isEmpty ? "This book" : title)” is already in your library, so it wasn’t added again."
            )
        case .failed(let message):
            importResult = ImportResult(
                title: "Could Not Add Book",
                message: message
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
