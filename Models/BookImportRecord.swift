import Foundation

/// A decoded book record from an exported BiblioBook JSON file.
///
/// `Book` itself is only `Encodable`, so imports decode into this lightweight
/// mirror type and are then converted into `Book` model instances. Every field
/// is decoded leniently with a sensible default so that partial or hand-edited
/// JSON files still import cleanly.
struct BookImportRecord: Decodable {
    var title = ""
    var author = ""
    var comment = ""
    var format = ""
    var genre = ""
    var series = ""
    var iSBN = ""
    var location = ""
    var bookCondition = ""
    var progress = ""
    var lentTo = ""
    var dateLent: Date? = nil
    var returnDate: Date? = nil
    var rating = 0
    var review = ""
    var createDate = Date.now
    var acquisitionDate: Date? = nil
    var cost = 0.0
    var source = ""
    var publisher = ""
    var copyrightDate = ""
    var coverData: Data? = nil
    var image1Data: Data? = nil
    var image2Data: Data? = nil
    var image3Data: Data? = nil
    var image4Data: Data? = nil
    var imageRotation1 = 0.0
    var imageRotation2 = 0.0
    var imageRotation3 = 0.0
    var imageRotation4 = 0.0
    var bChecksum = ""

    private enum CodingKeys: String, CodingKey {
        case title, author, comment, format, genre, series, iSBN, location
        case bookCondition, progress, lentTo, dateLent, returnDate, rating, review
        case createDate, acquisitionDate, cost, source, publisher, copyrightDate
        case coverData, image1Data, image2Data, image3Data, image4Data
        case imageRotation1, imageRotation2, imageRotation3, imageRotation4
        case bChecksum
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        author = try container.decodeIfPresent(String.self, forKey: .author) ?? ""
        comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
        format = try container.decodeIfPresent(String.self, forKey: .format) ?? ""
        genre = try container.decodeIfPresent(String.self, forKey: .genre) ?? ""
        series = try container.decodeIfPresent(String.self, forKey: .series) ?? ""
        iSBN = try container.decodeIfPresent(String.self, forKey: .iSBN) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        bookCondition = try container.decodeIfPresent(String.self, forKey: .bookCondition) ?? ""
        progress = try container.decodeIfPresent(String.self, forKey: .progress) ?? ""
        lentTo = try container.decodeIfPresent(String.self, forKey: .lentTo) ?? ""
        dateLent = try container.decodeIfPresent(Date.self, forKey: .dateLent)
        returnDate = try container.decodeIfPresent(Date.self, forKey: .returnDate)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        review = try container.decodeIfPresent(String.self, forKey: .review) ?? ""
        createDate = try container.decodeIfPresent(Date.self, forKey: .createDate) ?? Date.now
        acquisitionDate = try container.decodeIfPresent(Date.self, forKey: .acquisitionDate)
        cost = try container.decodeIfPresent(Double.self, forKey: .cost) ?? 0.0
        source = try container.decodeIfPresent(String.self, forKey: .source) ?? ""
        publisher = try container.decodeIfPresent(String.self, forKey: .publisher) ?? ""
        copyrightDate = try container.decodeIfPresent(String.self, forKey: .copyrightDate) ?? ""
        coverData = try container.decodeIfPresent(Data.self, forKey: .coverData)
        image1Data = try container.decodeIfPresent(Data.self, forKey: .image1Data)
        image2Data = try container.decodeIfPresent(Data.self, forKey: .image2Data)
        image3Data = try container.decodeIfPresent(Data.self, forKey: .image3Data)
        image4Data = try container.decodeIfPresent(Data.self, forKey: .image4Data)
        imageRotation1 = try container.decodeIfPresent(Double.self, forKey: .imageRotation1) ?? 0.0
        imageRotation2 = try container.decodeIfPresent(Double.self, forKey: .imageRotation2) ?? 0.0
        imageRotation3 = try container.decodeIfPresent(Double.self, forKey: .imageRotation3) ?? 0.0
        imageRotation4 = try container.decodeIfPresent(Double.self, forKey: .imageRotation4) ?? 0.0
        bChecksum = try container.decodeIfPresent(String.self, forKey: .bChecksum) ?? ""
    }

    /// Builds a `Book` model from this record, stamping it with the given import batch.
    func makeBook(batchNumber: String) -> Book {
        Book(
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
            createDate: createDate,
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
            bChecksum: bChecksum,
            batchNumber: batchNumber
        )
    }
}
