import SwiftUI

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
