import SwiftUI
import SwiftData

/// The sidebar list of all books, sorted by title, with a tappable
/// alphanumeric index along the trailing edge for fast navigation.
struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.title) private var books: [Book]
    @Binding var selection: Book?

    @State private var isShowingAddBook = false
    @State private var isShowingUtilities = false
    @State private var isShowingImportExport = false
    @State private var isShowingHelp = false
    @State private var searchText = ""

    init(selection: Binding<Book?>) {
        self._selection = selection
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                ForEach(filteredBooks) { book in
                    BookRowView(book: book)
                        .tag(book)
                }
                .onDelete(perform: deleteBooks)
            }
            .overlay(alignment: .trailing) {
                if filteredBooks.count > 1 {
                    TitleIndexBar(activeKeys: activeIndexKeys) { key in
                        scroll(to: key, using: proxy)
                    }
                    .padding(.trailing, 2)
                }
            }
            .overlay {
                if books.isEmpty {
                    ContentUnavailableView(
                        "No Books Yet",
                        systemImage: "books.vertical",
                        description: Text("Tap the + button to add your first book, or generate sample books from Utilities.")
                    )
                } else if filteredBooks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search books")
        .navigationTitle("BiblioBook")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Book", systemImage: "plus") {
                    isShowingAddBook = true
                }
            }
            ToolbarOverflowMenu {
                Button("Utilities", systemImage: "wand.and.stars") {
                    isShowingUtilities = true
                }
                Button("Import & Export", systemImage: "square.and.arrow.up.on.square") {
                    isShowingImportExport = true
                }
                Button("Help", systemImage: "questionmark.circle") {
                    isShowingHelp = true
                }
            }
        }
        .sheet(isPresented: $isShowingAddBook) {
            BookAddView { newBook in
                selection = newBook
            }
        }
        .sheet(isPresented: $isShowingUtilities) {
            UtilitiesView()
        }
        .sheet(isPresented: $isShowingImportExport) {
            ImportExportView()
        }
        .sheet(isPresented: $isShowingHelp) {
            HelpView()
        }
    }

    /// Books matching the current search text across every text field,
    /// or all books when the search field is empty.
    private var filteredBooks: [Book] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return books }
        return books.filter { book in
            let textFields = [
                book.title, book.author, book.comment, book.format,
                book.genre, book.series, book.iSBN, book.location,
                book.bookCondition, book.progress, book.lentTo,
                book.review, book.source, book.publisher, book.copyrightDate
            ]
            return textFields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    /// The set of index keys that actually have at least one book.
    private var activeIndexKeys: Set<String> {
        Set(filteredBooks.map { TitleIndexBar.key(forTitle: $0.title) })
    }

    /// Scrolls to the first book whose title starts with the tapped index key.
    private func scroll(to key: String, using proxy: ScrollViewProxy) {
        guard let target = filteredBooks.first(where: { TitleIndexBar.key(forTitle: $0.title) == key }) else {
            return
        }
        withAnimation {
            proxy.scrollTo(target.id, anchor: .top)
        }
    }

    private func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            let book = filteredBooks[index]
            if selection == book {
                selection = nil
            }
            modelContext.delete(book)
        }
    }
}
