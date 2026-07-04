import Foundation

/// Generates realistic sample books for the Utilities screen.
enum SampleBookFactory {

    /// The maximum number of sample books that can be generated in one batch.
    static let maximumCount = 20

    private struct Seed {
        let title: String
        let author: String
        let genre: String
        let series: String
        let publisher: String
        let copyright: String
        let comment: String
    }

    private static let seeds: [Seed] = [
        Seed(title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Classic Fiction", series: "", publisher: "Scribner", copyright: "1925", comment: "The green light at the end of the dock."),
        Seed(title: "To Kill a Mockingbird", author: "Harper Lee", genre: "Classic Fiction", series: "", publisher: "J.B. Lippincott & Co.", copyright: "1960", comment: "A Pulitzer Prize winner."),
        Seed(title: "1984", author: "George Orwell", genre: "Dystopian", series: "", publisher: "Secker & Warburg", copyright: "1949", comment: "Big Brother is watching."),
        Seed(title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance", series: "", publisher: "T. Egerton", copyright: "1813", comment: "A truth universally acknowledged."),
        Seed(title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", series: "Middle-earth", publisher: "George Allen & Unwin", copyright: "1937", comment: "There and back again."),
        Seed(title: "Dune", author: "Frank Herbert", genre: "Science Fiction", series: "Dune Chronicles", publisher: "Chilton Books", copyright: "1965", comment: "The spice must flow."),
        Seed(title: "The Fellowship of the Ring", author: "J.R.R. Tolkien", genre: "Fantasy", series: "The Lord of the Rings", publisher: "George Allen & Unwin", copyright: "1954", comment: "One ring to rule them all."),
        Seed(title: "Foundation", author: "Isaac Asimov", genre: "Science Fiction", series: "Foundation", publisher: "Gnome Press", copyright: "1951", comment: "Psychohistory in action."),
        Seed(title: "The Catcher in the Rye", author: "J.D. Salinger", genre: "Classic Fiction", series: "", publisher: "Little, Brown and Company", copyright: "1951", comment: "Holden Caulfield's weekend."),
        Seed(title: "Brave New World", author: "Aldous Huxley", genre: "Dystopian", series: "", publisher: "Chatto & Windus", copyright: "1932", comment: "A gramme is better than a damn."),
        Seed(title: "Moby-Dick", author: "Herman Melville", genre: "Classic Fiction", series: "", publisher: "Harper & Brothers", copyright: "1851", comment: "Call me Ishmael."),
        Seed(title: "Jane Eyre", author: "Charlotte Bronte", genre: "Gothic Romance", series: "", publisher: "Smith, Elder & Co.", copyright: "1847", comment: "Reader, I married him."),
        Seed(title: "The Martian", author: "Andy Weir", genre: "Science Fiction", series: "", publisher: "Crown Publishing", copyright: "2011", comment: "Science the heck out of it."),
        Seed(title: "Educated", author: "Tara Westover", genre: "Memoir", series: "", publisher: "Random House", copyright: "2018", comment: "A remarkable journey to learning."),
        Seed(title: "Sapiens: A Brief History of Humankind", author: "Yuval Noah Harari", genre: "History", series: "", publisher: "Harper", copyright: "2015", comment: "How Homo sapiens took over."),
        Seed(title: "The Name of the Wind", author: "Patrick Rothfuss", genre: "Fantasy", series: "The Kingkiller Chronicle", publisher: "DAW Books", copyright: "2007", comment: "Waiting for book three."),
        Seed(title: "A Game of Thrones", author: "George R.R. Martin", genre: "Fantasy", series: "A Song of Ice and Fire", publisher: "Bantam Books", copyright: "1996", comment: "Winter is coming."),
        Seed(title: "The Da Vinci Code", author: "Dan Brown", genre: "Thriller", series: "Robert Langdon", publisher: "Doubleday", copyright: "2003", comment: "A page-turner through Paris."),
        Seed(title: "Where the Crawdads Sing", author: "Delia Owens", genre: "Literary Fiction", series: "", publisher: "G.P. Putnam's Sons", copyright: "2018", comment: "The marsh girl's story."),
        Seed(title: "The Silent Patient", author: "Alex Michaelides", genre: "Psychological Thriller", series: "", publisher: "Celadon Books", copyright: "2019", comment: "That twist!")
    ]

    private static let formats = ["Hardcover", "Paperback", "Trade Paperback", "eBook", "Audiobook"]
    private static let conditions = ["New", "Like New", "Very Good", "Good", "Fair", "Worn"]
    private static let progressStates = ["Not Started", "Reading", "Finished", "Abandoned"]
    private static let locations = ["Living Room Shelf A", "Living Room Shelf B", "Office Bookcase", "Bedroom Nightstand", "Study, Top Shelf", "Storage Box 3"]
    private static let sources = ["Local Bookstore", "Online Retailer", "Used Bookstore", "Library Sale", "Gift", "Estate Sale"]

    /// Creates up to `maximumCount` sample books with realistic titles and data.
    static func makeBooks(count: Int) -> [Book] {
        let clamped = max(1, min(count, maximumCount))
        let batch = "sample-" + Date.now.formatted(.iso8601)

        return seeds.shuffled().prefix(clamped).map { seed in
            let book = Book(
                title: seed.title,
                author: seed.author,
                comment: seed.comment,
                format: formats.randomElement() ?? "Paperback",
                genre: seed.genre,
                series: seed.series,
                iSBN: randomISBN(),
                location: locations.randomElement() ?? "",
                bookCondition: conditions.randomElement() ?? "Good",
                progress: progressStates.randomElement() ?? "Not Started",
                lentTo: "",
                rating: Int.random(in: 0...5),
                review: "",
                createDate: .now,
                acquisitionDate: randomPastDate(),
                cost: (Double.random(in: 4.99...39.99) * 100).rounded() / 100,
                source: sources.randomElement() ?? "",
                publisher: seed.publisher,
                copyrightDate: seed.copyright,
                batchNumber: batch
            )
            book.bChecksum = book.bookChecksum()
            return book
        }
    }

    private static func randomISBN() -> String {
        let body = (0..<10).map { _ in String(Int.random(in: 0...9)) }.joined()
        return "978" + body
    }

    private static func randomPastDate() -> Date {
        let daysAgo = Double(Int.random(in: 10...2_000))
        return Date.now.addingTimeInterval(-daysAgo * 24 * 60 * 60)
    }
}
