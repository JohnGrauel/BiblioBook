import SwiftUI
import SwiftData

/// The photo sections of the book form: one cover slot plus four
/// additional photo slots, each with its own stored rotation.
struct BookPhotosSection: View {
    @Bindable var book: Book

    var body: some View {
        Section("Cover") {
            BookPhotoSlot(title: "Cover", imageData: $book.coverData)
        }

        Section("Photos") {
            BookPhotoSlot(title: "Photo 1", imageData: $book.image1Data, rotation: $book.imageRotation1, style: .compact)
            BookPhotoSlot(title: "Photo 2", imageData: $book.image2Data, rotation: $book.imageRotation2, style: .compact)
            BookPhotoSlot(title: "Photo 3", imageData: $book.image3Data, rotation: $book.imageRotation3, style: .compact)
            BookPhotoSlot(title: "Photo 4", imageData: $book.image4Data, rotation: $book.imageRotation4, style: .compact)
        }
    }
}

/// Renders a flat-color placeholder photo so the preview has image data to show.
private func previewPhotoData(_ color: UIColor) -> Data? {
    let size = CGSize(width: 300, height: 400)
    return UIGraphicsImageRenderer(size: size).image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }.pngData()
}

#Preview {
    let container = try! ModelContainer(
        for: Book.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let book = SampleBookFactory.makeBooks(count: 1)[0]
    book.coverData = previewPhotoData(.systemBrown)
    book.image1Data = previewPhotoData(.systemTeal)
    book.image2Data = previewPhotoData(.systemIndigo)
    container.mainContext.insert(book)
    return Form {
        BookPhotosSection(book: book)
    }
    .modelContainer(container)
}
