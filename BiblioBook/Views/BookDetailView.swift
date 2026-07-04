import SwiftUI
import SwiftData

/// Shows every detail of a book and allows direct, in-place editing.
/// Changes are written straight to the SwiftData model and explicitly
/// saved when the view disappears.
struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var book: Book

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
        .onDisappear {
            saveEdits()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                saveEdits()
            }
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
