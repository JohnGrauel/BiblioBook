import SwiftUI
import SwiftData

/// Shows every detail of a book and allows direct, in-place editing.
/// Changes are written straight to the SwiftData model and explicitly
/// saved when the view disappears.
struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var book: Book

    /// Wraps the temporary `.bibliobook` file URL so it can drive a sheet.
    private struct ShareItem: Identifiable {
        let id = UUID()
        let url: URL
    }

    @State private var shareItem: ShareItem? = nil
    @State private var shareError: String? = nil

    var body: some View {
        Form {
            Section {
                BookPhotoCarousel(book: book)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section("Book") {
                TextField("Title", text: $book.title)
                TextField("Author", text: $book.author)
                TextField("Series", text: $book.series)
                TextField("Genre", text: $book.genre)
                TextField("Format", text: $book.format)
                TextField("ISBN", text: $book.iSBN)
            }

            Section("Publication") {
                TextField("Publisher", text: $book.publisher)
                TextField("Copyright Date", text: $book.copyrightDate)
            }

            Section("My Copy") {
                TextField("Location", text: $book.location)
                TextField("Condition", text: $book.bookCondition)
                TextField("Reading Progress", text: $book.progress)
                OptionalDateRow(title: "Acquired", date: $book.acquisitionDate)
                TextField("Source", text: $book.source)
                HStack {
                    Text("Cost")
                    Spacer()
                    TextField("Cost", value: $book.cost, format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .labelsHidden()
                }
            }

            Section("Rating & Review") {
                StarRatingView(rating: $book.rating)
                TextField("Review", text: $book.review, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Lending") {
                TextField("Lent To", text: $book.lentTo)
                OptionalDateRow(title: "Date Lent", date: $book.dateLent)
                OptionalDateRow(title: "Return Date", date: $book.returnDate)
            }

            Section("Comment") {
                TextField("Comment", text: $book.comment, axis: .vertical)
                    .lineLimit(2...6)
            }

            BookPhotosSection(book: book)

            Section("Record Info") {
                LabeledContent("Added", value: book.createDate.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Batch", value: book.batchNumber)
            }
        }
        .navigationTitle(book.title.isEmpty ? "Book Details" : book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Share Book", systemImage: "square.and.arrow.up") {
                    shareBook()
                }
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.url])
        }
        .alert("Could Not Share Book", isPresented: shareErrorBinding, presenting: shareError) { _ in
            Button("OK", role: .cancel) { }
        } message: { message in
            Text(message)
        }
        .onDisappear {
            saveEdits()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                saveEdits()
            }
        }
    }

    private var shareErrorBinding: Binding<Bool> {
        Binding(
            get: { shareError != nil },
            set: { if !$0 { shareError = nil } }
        )
    }

    /// Flushes pending edits, writes a `.bibliobook` file, and presents the
    /// share sheet so the book can be sent by email (or any other service).
    private func shareBook() {
        saveEdits()
        do {
            let url = try BookSharing.exportFile(for: book)
            shareItem = ShareItem(url: url)
        } catch {
            shareError = error.localizedDescription
        }
    }

    /// Refreshes the checksum and flushes pending edits to the store.
    private func saveEdits() {
        book.bChecksum = book.bookChecksum()
        do {
            try modelContext.save()
        } catch {
            print("Failed to save book edits: \(error)")
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Book.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let book = SampleBookFactory.makeBooks(count: 1)[0]
    container.mainContext.insert(book)
    return NavigationStack {
        BookDetailView(book: book)
    }
    .modelContainer(container)
}
