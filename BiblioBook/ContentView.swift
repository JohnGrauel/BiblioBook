import SwiftUI
import SwiftData

/// The root split view: the book list in the sidebar, details on the right.
struct ContentView: View {
    @State private var selectedBook: Book? = nil

    var body: some View {
        NavigationSplitView {
            BookListView(selection: $selectedBook)
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
