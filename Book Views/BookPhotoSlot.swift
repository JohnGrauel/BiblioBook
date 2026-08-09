import SwiftUI
import PhotosUI

/// One photo slot in a book form. Shows the stored image (honoring its
/// rotation) with rotate/remove controls, or - when empty - buttons to pick
/// a photo from the library or take one with the camera. Every image is
/// compressed to at most 200 KB before being stored.
struct BookPhotoSlot: View {
    /// How a filled slot presents its image. `.full` shows a large preview
    /// with rotate/remove controls; `.compact` shows a thumbnail row with
    /// remove only, for forms where display lives elsewhere (the carousel).
    enum Style {
        case full
        case compact
    }

    let title: String
    @Binding var imageData: Data?
    var rotation: Binding<Double>?
    let style: Style

    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var isShowingCamera = false

    init(title: String, imageData: Binding<Data?>, rotation: Binding<Double>? = nil, style: Style = .full) {
        self.title = title
        self._imageData = imageData
        self.rotation = rotation
        self.style = style
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData, let uiImage = UIImage(data: imageData), style == .compact {
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(rotation?.wrappedValue ?? 0))
                        .clipShape(.rect(cornerRadius: 6))
                    Text(title)
                    Spacer()
                    Button("Remove", systemImage: "trash", role: .destructive) {
                        self.imageData = nil
                        rotation?.wrappedValue = 0
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                }
            } else if let imageData, let uiImage = UIImage(data: imageData) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(rotation?.wrappedValue ?? 0))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                HStack {
                    if let rotation {
                        Button("Rotate", systemImage: "rotate.right") {
                            rotation.wrappedValue = (rotation.wrappedValue + 90)
                                .truncatingRemainder(dividingBy: 360)
                        }
                    }
                    Spacer()
                    Button("Remove", systemImage: "trash", role: .destructive) {
                        self.imageData = nil
                        rotation?.wrappedValue = 0
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
            } else {
                HStack {
                    Text(title)
                    Spacer()
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Library", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(.borderless)
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("Camera", systemImage: "camera") {
                            isShowingCamera = true
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let compressed = await ImageCompressor.compressedData(from: data) {
                    imageData = compressed
                }
                pickerItem = nil
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { capturedImage in
                Task {
                    imageData = await ImageCompressor.compressedData(from: capturedImage)
                }
            }
            .ignoresSafeArea()
        }
    }
}
