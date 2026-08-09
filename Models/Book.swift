import Foundation
import SwiftData
import CryptoKit

@Model
class Book: Hashable, Encodable {

    var title: String = ""
    var author: String = ""
    var comment: String = ""
    var format: String = ""
    var genre: String = ""
    var series: String = ""
    var iSBN: String = ""
    var location: String = ""
    var bookCondition: String = ""
    var progress: String = ""
    var lentTo: String = ""
    var dateLent: Date? = nil
    var returnDate: Date? = nil
    var rating: Int = 0
    var review: String = ""
    var createDate: Date = Date.now
    var acquisitionDate: Date? = nil

    var cost: Double = 0.0
    var source: String = ""
    var publisher: String = ""
    var copyrightDate: String = ""

    var coverData: Data? = nil
    var image1Data: Data? = nil
    var image2Data: Data? = nil
    var image3Data: Data? = nil
    var image4Data: Data? = nil
    var imageRotation1: Double = 0.0
    var imageRotation2: Double = 0.0
    var imageRotation3: Double = 0.0
    var imageRotation4: Double = 0.0

    var bChecksum: String = ""
    var batchNumber: String = "notimported"

    init(
        title: String,
        author: String,
        comment: String,
        format: String,
        genre: String,
        series: String,
        iSBN: String,
        location: String,
        bookCondition: String,
        progress: String,
        lentTo: String,
        dateLent: Date? = nil,
        returnDate: Date? = nil,
        rating: Int,
        review: String,
        createDate: Date,
        acquisitionDate: Date? = nil,
        cost: Double,
        source: String,
        publisher: String,
        copyrightDate: String,
        coverData: Data? = nil,
        image1Data: Data? = nil,
        image2Data: Data? = nil,
        image3Data: Data? = nil,
        image4Data: Data? = nil,
        imageRotation1: Double = 0.0,
        imageRotation2: Double = 0.0,
        imageRotation3: Double = 0.0,
        imageRotation4: Double = 0.0,
        bChecksum: String = "",
        batchNumber: String
    ) {
        self.title = title
        self.author = author
        self.comment = comment
        self.format = format
        self.genre = genre
        self.series = series
        self.iSBN = iSBN
        self.location = location
        self.bookCondition = bookCondition
        self.progress = progress
        self.lentTo = lentTo
        self.dateLent = dateLent
        self.returnDate = returnDate
        self.rating = rating
        self.review = review
        self.createDate = createDate
        self.acquisitionDate = acquisitionDate
        self.cost = cost
        self.source = source
        self.publisher = publisher
        self.copyrightDate = copyrightDate
        self.coverData = coverData
        self.image1Data = image1Data
        self.image2Data = image2Data
        self.image3Data = image3Data
        self.image4Data = image4Data
        self.imageRotation1 = imageRotation1
        self.imageRotation2 = imageRotation2
        self.imageRotation3 = imageRotation3
        self.imageRotation4 = imageRotation4
        self.bChecksum = bChecksum
        self.batchNumber = batchNumber
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case comment
        case format
        case genre
        case series
        case iSBN
        case location
        case bookCondition
        case progress
        case lentTo
        case dateLent
        case returnDate
        case rating
        case review
        case createDate
        case acquisitionDate
        case cost
        case source
        case publisher
        case copyrightDate
        case coverData
        case image1Data
        case image2Data
        case image3Data
        case image4Data
        case imageRotation1
        case imageRotation2
        case imageRotation3
        case imageRotation4
        case bChecksum
        case batchNumber
    }//enum

    //MARK: - Encode

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(comment, forKey: .comment)
        try container.encode(format, forKey: .format)
        try container.encode(genre, forKey: .genre)

        try container.encode(series, forKey: .series)
        try container.encode(iSBN, forKey: .iSBN)
        try container.encode(location, forKey: .location)
        try container.encode(bookCondition, forKey: .bookCondition)
        try container.encode(progress, forKey: .progress)
        try container.encode(lentTo, forKey: .lentTo)

        try container.encode(dateLent, forKey: .dateLent)
        try container.encode(returnDate, forKey: .returnDate)

        try container.encode(rating, forKey: .rating)
        try container.encode(review, forKey: .review)

        try container.encode(createDate, forKey: .createDate)
        try container.encode(acquisitionDate, forKey: .acquisitionDate)

        try container.encode(cost, forKey: .cost)
        try container.encode(source, forKey: .source)
        try container.encode(publisher, forKey: .publisher)
        try container.encode(copyrightDate, forKey: .copyrightDate)

        try container.encode(coverData, forKey: .coverData)
        try container.encode(image1Data, forKey: .image1Data)
        try container.encode(image2Data, forKey: .image2Data)
        try container.encode(image3Data, forKey: .image3Data)
        try container.encode(image4Data, forKey: .image4Data)

        try container.encode(imageRotation1, forKey: .imageRotation1)
        try container.encode(imageRotation2, forKey: .imageRotation2)
        try container.encode(imageRotation3, forKey: .imageRotation3)
        try container.encode(imageRotation4, forKey: .imageRotation4)

        try container.encode(bChecksum, forKey: .bChecksum)
        try container.encode(batchNumber, forKey: .batchNumber)

    }//encode
}//class

extension Book {
    func bookChecksum() -> String {
        // Combine relevant values into a string

        //you removed \(createDate)
        let combinedString = "\(title)\(author)\(comment)\(format)\(genre)\(series)\(iSBN)\(location)\(bookCondition)\(progress)\(lentTo)\(String(describing: dateLent))\(String(describing: returnDate))\(rating)\(review)\(String(describing: acquisitionDate))\(cost)\(source)\(publisher)\(copyrightDate)"

        // Generate a hash of the combined string using SHA256
        let data = Data(combinedString.utf8)
        let hash = SHA256.hash(data: data)

        // Convert the hash to a hexadecimal string representation
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }//checksum
}//ext Book
