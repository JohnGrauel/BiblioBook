import SwiftUI
import SwiftData

/// Housekeeping tools, including a sample-data generator that adds up to
/// 20 realistic books so the app can be explored without manual data entry.
struct UtilitiesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var books: [Book]

    @State private var sampleCount = 5
    @State private var resultMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Library") {
                    LabeledContent("Books in library", value: "\(books.count)")
                }

                Section {
                    Stepper("Number of books: \(sampleCount)", value: $sampleCount, in: 1...SampleBookFactory.maximumCount)
                    Button("Generate Sample Books", systemImage: "wand.and.stars") {
                        generateSamples()
                    }
                    if let resultMessage {
                        Text(resultMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Sample Data")
                } footer: {
                    Text("Adds up to \(SampleBookFactory.maximumCount) sample books with realistic titles, authors, and details so you can explore the app.")
                }
            }
            .navigationTitle("Utilities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func generateSamples() {
        let newBooks = SampleBookFactory.makeBooks(count: sampleCount)
        for book in newBooks {
            modelContext.insert(book)
        }
        resultMessage = "Added \(newBooks.count) sample book\(newBooks.count == 1 ? "" : "s")."
    }
}
