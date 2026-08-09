import SwiftUI

/// A vertical alphanumeric index bar, similar to the one in Contacts.
/// Tapping a letter jumps the list to the first book whose title starts
/// with that letter. Titles that don't start with A-Z group under "#".
struct TitleIndexBar: View {
    let activeKeys: Set<String>
    let onSelect: (String) -> Void

    static let allKeys: [String] = ["#"] + "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map(String.init)

    /// Maps a book title to its index key: its first letter uppercased,
    /// or "#" when the title starts with a digit, symbol, or is empty.
    static func key(forTitle title: String) -> String {
        guard let first = title.trimmingCharacters(in: .whitespacesAndNewlines).first else {
            return "#"
        }
        let upper = String(first).uppercased()
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(upper) ? upper : "#"
    }

    var body: some View {
        VStack(spacing: 1) {
            ForEach(Self.allKeys, id: \.self) { key in
                Button {
                    onSelect(key)
                } label: {
                    Text(key)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(activeKeys.contains(key) ? Color.accentColor : Color.secondary.opacity(0.4))
                        .frame(width: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!activeKeys.contains(key))
                .accessibilityLabel("Jump to titles starting with \(key)")
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
        .glassEffect(.regular, in: .capsule)
    }
}
