import Foundation
import SwiftData
import UniformTypeIdentifiers

extension UTType {
    /// A single BiblioBook record shared between users, saved with the
    /// `.bibliobook` file extension. This type is declared as an *exported*
    /// type in Info.plist, and registered as a document type the app *owns*,
    /// so that tapping a `.bibliobook` mail attachment launches BiblioBook.
    static let biblioBook = UTType(exportedAs: "com.catalpa.bibliobook.book", conformingTo: .json)
}

/// Encodes a single `Book` to a shareable `.bibliobook` file and imports one
/// back into the store. The on-disk format is exactly the JSON produced by the
/// library exporter (one book instead of an array), so shared files decode
/// through the same `BookImportRecord` path and are de-duplicated by checksum.
enum BookSharing {

    /// The outcome of importing a shared book file.
    enum ImportOutcome {
        case imported(Book)
        case duplicate(title: String)
        case failed(message: String)
    }

    /// Writes the book to a `.bibliobook` file in the temporary directory and
    /// returns its URL, ready to hand to the system share sheet.
    static func exportFile(for book: Book) throws -> URL {
        // Refresh the checksum so the recipient can de-duplicate reliably.
        book.bChecksum = book.bookChecksum()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(book)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(shareFileName(for: book))
        try data.write(to: url, options: .atomic)
        return url
    }

    /// A friendly, filesystem-safe filename ending in `.bibliobook`.
    static func shareFileName(for book: Book) -> String {
        let base = book.title.isEmpty ? "Shared Book" : book.title
        let illegal = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let safe = base.components(separatedBy: illegal).joined(separator: "-")
        return "\(safe).bibliobook"
    }

    /// Decodes a shared `.bibliobook` file and inserts the book into the store,
    /// skipping it when a book with the same checksum already exists.
    static func importBook(from url: URL, into context: ModelContext) -> ImportOutcome {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            // A shared file holds a single book, but tolerate an exported
            // array too, importing its first record.
            let record: BookImportRecord
            if let single = try? decoder.decode(BookImportRecord.self, from: data) {
                record = single
            } else if let first = try decoder.decode([BookImportRecord].self, from: data).first {
                record = first
            } else {
                return .failed(message: "The shared file did not contain a book.")
            }

            let batch = "shared-" + Date.now.formatted(.iso8601)
            let book = record.makeBook(batchNumber: batch)
            if book.bChecksum.isEmpty {
                book.bChecksum = book.bookChecksum()
            }

            let checksum = book.bChecksum
            var descriptor = FetchDescriptor<Book>(predicate: #Predicate { $0.bChecksum == checksum })
            descriptor.fetchLimit = 1
            if let existing = try context.fetch(descriptor).first {
                return .duplicate(title: existing.title)
            }

            context.insert(book)
            try context.save()
            return .imported(book)
        } catch {
            return .failed(message: error.localizedDescription)
        }
    }
}
