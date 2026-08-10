import SwiftUI
import SwiftData

/// The starting place for new entries: collects a new book's details and
/// photos, then inserts it into the library on Save.
struct BookAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let onSaved: ((Book) -> Void)?

    @State private var title = ""
    @State private var author = ""
    @State private var series = ""
    @State private var genre = ""
    @State private var format = ""
    @State private var iSBN = ""
    @State private var publisher = ""
    @State private var copyrightDate = ""
    @State private var location = ""
    @State private var bookCondition = ""
    @State private var progress = ""
    @State private var acquisitionDate: Date? = nil
    @State private var source = ""
    @State private var cost = 0.0
    @State private var rating = 0
    @State private var review = ""
    @State private var lentTo = ""
    @State private var dateLent: Date? = nil
    @State private var returnDate: Date? = nil
    @State private var comment = ""
    @State private var coverData: Data? = nil
    @State private var image1Data: Data? = nil
    @State private var image2Data: Data? = nil
    @State private var image3Data: Data? = nil
    @State private var image4Data: Data? = nil
    @State private var imageRotation1 = 0.0
    @State private var imageRotation2 = 0.0
    @State private var imageRotation3 = 0.0
    @State private var imageRotation4 = 0.0

    init(onSaved: ((Book) -> Void)? = nil) {
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Book") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Series", text: $series)
                    TextField("Genre", text: $genre)
                    TextField("Format", text: $format)
                    TextField("ISBN", text: $iSBN)
                }

                Section("Publication") {
                    TextField("Publisher", text: $publisher)
                    TextField("Copyright Date", text: $copyrightDate)
                }

                Section("My Copy") {
                    TextField("Location", text: $location)
                    TextField("Condition", text: $bookCondition)
                    TextField("Reading Progress", text: $progress)
                    OptionalDateRow(title: "Acquired", date: $acquisitionDate)
                    TextField("Source", text: $source)
                    HStack {
                        Text("Cost")
                        Spacer()
                        TextField("Cost", value: $cost, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .labelsHidden()
                    }
                }

                Section("Rating & Review") {
                    StarRatingView(rating: $rating)
                    TextField("Review", text: $review, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Lending") {
                    TextField("Lent To", text: $lentTo)
                    OptionalDateRow(title: "Date Lent", date: $dateLent)
                    OptionalDateRow(title: "Return Date", date: $returnDate)
                }

                Section("Comment") {
                    TextField("Comment", text: $comment, axis: .vertical)
                        .lineLimit(2...6)
                }

                Section("Cover") {
                    BookPhotoSlot(title: "Cover", imageData: $coverData)
                }

                Section("Photos") {
                    BookPhotoSlot(title: "Photo 1", imageData: $image1Data, rotation: $imageRotation1)
                    BookPhotoSlot(title: "Photo 2", imageData: $image2Data, rotation: $imageRotation2)
                    BookPhotoSlot(title: "Photo 3", imageData: $image3Data, rotation: $imageRotation3)
                    BookPhotoSlot(title: "Photo 4", imageData: $image4Data, rotation: $imageRotation4)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let book = Book(
            title: title,
            author: author,
            comment: comment,
            format: format,
            genre: genre,
            series: series,
            iSBN: iSBN,
            location: location,
            bookCondition: bookCondition,
            progress: progress,
            lentTo: lentTo,
            dateLent: dateLent,
            returnDate: returnDate,
            rating: rating,
            review: review,
            createDate: .now,
            acquisitionDate: acquisitionDate,
            cost: cost,
            source: source,
            publisher: publisher,
            copyrightDate: copyrightDate,
            coverData: coverData,
            image1Data: image1Data,
            image2Data: image2Data,
            image3Data: image3Data,
            image4Data: image4Data,
            imageRotation1: imageRotation1,
            imageRotation2: imageRotation2,
            imageRotation3: imageRotation3,
            imageRotation4: imageRotation4,
            batchNumber: "manual"
        )
        book.bChecksum = book.bookChecksum()
        modelContext.insert(book)
        onSaved?(book)
        dismiss()
    }
}

#Preview {
    BookAddView()
        .modelContainer(try! ModelContainer(
            for: Book.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ))
}
