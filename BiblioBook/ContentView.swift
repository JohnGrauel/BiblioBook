import SwiftUI
import SwiftData

/// The root split view: the book list in the sidebar, details on the right.
struct ContentView: View {
    @State private var selectedBook: Book? = nil
    
    @Query private var books: [Book]

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
    }//body
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
