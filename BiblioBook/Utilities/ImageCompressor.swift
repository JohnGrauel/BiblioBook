import UIKit

/// Compresses images so their stored JPEG data never exceeds 200 KB.
///
/// The strategy is: try decreasing JPEG quality first, and if that is not
/// enough, scale the image down and try again. Compression runs off the main
/// actor (`@concurrent`) so large camera photos never stall the UI.
nonisolated enum ImageCompressor {

    /// The maximum allowed size for stored image data: 200 KB.
    static let maxByteCount = 200 * 1024

    /// Compresses raw image data (for example from the photo library).
    @concurrent
    static func compressedData(from data: Data, maxBytes: Int = maxByteCount) async -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return compress(image, maxBytes: maxBytes)
    }

    /// Compresses a `UIImage` (for example a fresh camera capture).
    @concurrent
    static func compressedData(from image: UIImage, maxBytes: Int = maxByteCount) async -> Data? {
        compress(image, maxBytes: maxBytes)
    }

    private static func compress(_ image: UIImage, maxBytes: Int) -> Data? {
        var working = image
        for _ in 0..<10 {
            var quality: CGFloat = 0.85
            while quality >= 0.4 {
                if let data = working.jpegData(compressionQuality: quality), data.count <= maxBytes {
                    return data
                }
                quality -= 0.15
            }
            working = resized(working, scale: 0.7)
        }
        return working.jpegData(compressionQuality: 0.4)
    }

    private static func resized(_ image: UIImage, scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
