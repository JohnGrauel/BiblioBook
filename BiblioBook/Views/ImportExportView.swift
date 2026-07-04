import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Exports the whole library to a JSON file (savable to iCloud Drive via the
/// Files document picker) and imports previously exported JSON files.
/// Imported books already present in the library, matched by checksum,
/// are skipped.
struct ImportExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var books: [Book]

    @State private var exportDocument: JSONDocument? = nil
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var statusMessage: String? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Books to export", value: "\(books.count)")
                    Button("Export All Books to JSON", systemImage: "square.and.arrow.up") {
                        prepareExport()
                    }
                    .disabled(books.isEmpty)
                } header: {
                    Text("Export")
                } footer: {
                    Text("Save the file anywhere in the Files app, including iCloud Drive.")
                }

                Section {
                    Button("Import Books from JSON", systemImage: "square.and.arrow.down") {
                        isImporting = true
                    }
                } header: {
                    Text("Import")
                } footer: {
                    Text("Choose a JSON file previously exported from BiblioBook. Books already in your library (matched by checksum) are skipped.")
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Import & Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .fileExporter(
                isPresented: $isExporting,
                document: exportDocument,
                contentType: .json,
                defaultFilename: defaultExportName
            ) { result in
                switch result {
                case .success(let url):
                    statusMessage = "Exported \(books.count) book\(books.count == 1 ? "" : "s") to \(url.lastPathComponent)."
                    errorMessage = nil
                case .failure(let error):
                    errorMessage = "Export failed: \(error.localizedDescription)"
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    importBooks(from: url)
                case .failure(let error):
                    errorMessage = "Import failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private var defaultExportName: String {
        "BiblioBook-" + Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    }

    private func prepareExport() {
        do {
            // Refresh every checksum so exported records can be de-duplicated on import.
            for book in books {
                book.bChecksum = book.bookChecksum()
            }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(books)
            exportDocument = JSONDocument(data: data)
            isExporting = true
        } catch {
            errorMessage = "Could not prepare export: \(error.localizedDescription)"
        }
    }

    private func importBooks(from url: URL) {
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
            let records = try decoder.decode([BookImportRecord].self, from: data)

            let existingChecksums = Set(books.map(\.bChecksum))
            let batch = "import-" + Date.now.formatted(.iso8601)
            var imported = 0
            var skipped = 0

            for record in records {
                let book = record.makeBook(batchNumber: batch)
                if book.bChecksum.isEmpty {
                    book.bChecksum = book.bookChecksum()
                }
                if existingChecksums.contains(book.bChecksum) {
                    skipped += 1
                    continue
                }
                modelContext.insert(book)
                imported += 1
            }

            statusMessage = skipped > 0
                ? "Imported \(imported) book\(imported == 1 ? "" : "s"), skipped \(skipped) duplicate\(skipped == 1 ? "" : "s")."
                : "Imported \(imported) book\(imported == 1 ? "" : "s")."
            errorMessage = nil
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }
}
