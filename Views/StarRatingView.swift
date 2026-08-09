import SwiftUI

/// A tappable five-star rating control. Tapping the current rating again
/// clears it back to zero.
struct StarRatingView: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating = (rating == star) ? 0 : star
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(star <= rating ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rate \(star) star\(star == 1 ? "" : "s")")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityValue("\(rating) of 5 stars")
    }
}
