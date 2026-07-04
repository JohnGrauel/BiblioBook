import SwiftUI

/// A single row in the book list: cover thumbnail, title, author,
/// and a lending indicator when the book is out on loan.
struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(spacing: 12) {
            coverThumbnail
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title.isEmpty ? "Untitled" : book.title)
                    .font(.headline)
                    .lineLimit(1)
                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                if !book.lentTo.isEmpty {
                    Label("Lent to \(book.lentTo)", systemImage: "person.crop.circle.badge.clock")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        // Keep row content clear of the trailing index bar.
        .padding(.trailing, 14)
    }

    @ViewBuilder
    private var coverThumbnail: some View {
        if let data = book.coverData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 34, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            Image(systemName: "book.closed")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 48)
        }
    }
}
