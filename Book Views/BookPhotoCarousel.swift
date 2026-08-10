import SwiftUI
import SwiftData

/// A horizontally paging carousel for the four book photos, shown at the
/// top of the detail view. Each photo fills one page; the indicator dots
/// jump to a photo and the rotate button turns the currently visible one.
/// (Pattern adapted from the BooksRUs detail view.)
struct BookPhotoCarousel: View {
    @Bindable var book: Book

    @State private var scrollID: Int? = nil

    init(book: Book) {
        self.book = book
    }

    /// Slot indices (0–3) that currently hold a photo, in order.
    private var occupiedSlots: [Int] {
        [book.image1Data, book.image2Data, book.image3Data, book.image4Data]
            .enumerated()
            .compactMap { $0.element != nil ? $0.offset : nil }
    }

    var body: some View {
        if occupiedSlots.isEmpty {
            Text("No photos to display")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 12) {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(occupiedSlots, id: \.self) { slot in
                            if let data = imageData(forSlot: slot),
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(.rect(cornerRadius: 25))
                                    .frame(width: 300, height: 300)
                                    .rotationEffect(.degrees(rotation(forSlot: slot)))
                                    .animation(.easeInOut, value: rotation(forSlot: slot))
                                    .containerRelativeFrame(.horizontal)
                                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.6)
                                    }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollPosition(id: $scrollID)
                .scrollTargetBehavior(.viewAligned)

                HStack(spacing: 12) {
                    indicatorDots
                    Button {
                        rotateVisiblePhoto()
                    } label: {
                        Image(systemName: "rotate.right")
                            .imageScale(.large)
                            .bold()
                    }
                    .accessibilityLabel("Rotate photo")
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 10))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
        }
    }

    /// One tappable dot per photo; the dot for the visible page is filled.
    private var indicatorDots: some View {
        HStack {
            ForEach(occupiedSlots, id: \.self) { slot in
                let currentSlot = scrollID ?? occupiedSlots.first
                Button {
                    withAnimation {
                        scrollID = slot
                    }
                } label: {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(slot == currentSlot ? Color.accentColor : Color.secondary.opacity(0.4))
                }
                .accessibilityLabel("Photo \(slot + 1)")
            }
        }
        .padding(7)
        .background(.quaternary, in: .rect(cornerRadius: 10))
    }

    private func imageData(forSlot slot: Int) -> Data? {
        switch slot {
        case 0: book.image1Data
        case 1: book.image2Data
        case 2: book.image3Data
        case 3: book.image4Data
        default: nil
        }
    }

    private func rotation(forSlot slot: Int) -> Double {
        switch slot {
        case 0: book.imageRotation1
        case 1: book.imageRotation2
        case 2: book.imageRotation3
        case 3: book.imageRotation4
        default: 0
        }
    }

    /// Rotates the photo on the current page by 90°, persisting via the
    /// book's stored rotation so every other view stays in sync.
    private func rotateVisiblePhoto() {
        guard let slot = scrollID ?? occupiedSlots.first else { return }
        switch slot {
        case 0:
            book.imageRotation1 = (book.imageRotation1 + 90).truncatingRemainder(dividingBy: 360)
        case 1:
            book.imageRotation2 = (book.imageRotation2 + 90).truncatingRemainder(dividingBy: 360)
        case 2:
            book.imageRotation3 = (book.imageRotation3 + 90).truncatingRemainder(dividingBy: 360)
        case 3:
            book.imageRotation4 = (book.imageRotation4 + 90).truncatingRemainder(dividingBy: 360)
        default:
            break
        }
    }
}

/// Renders a flat-color placeholder photo so the preview has image data to show.
private func previewPhotoData(_ color: UIColor) -> Data? {
    let size = CGSize(width: 300, height: 400)
    return UIGraphicsImageRenderer(size: size).image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }.pngData()
}

#Preview {
    let container = try! ModelContainer(
        for: Book.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let book = SampleBookFactory.makeBooks(count: 1)[0]
    book.image1Data = previewPhotoData(.systemTeal)
    book.image2Data = previewPhotoData(.systemIndigo)
    book.image3Data = previewPhotoData(.systemOrange)
    container.mainContext.insert(book)
    return Form {
        Section {
            BookPhotoCarousel(book: book)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    .modelContainer(container)
}
