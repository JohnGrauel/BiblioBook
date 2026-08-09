import SwiftUI

/// A form row for an optional date: a toggle that enables the date, and a
/// date picker shown only while a date is set.
struct OptionalDateRow: View {
    let title: String
    @Binding var date: Date?

    var body: some View {
        Toggle(title, isOn: hasDate)
        if date != nil {
            DatePicker(selection: unwrappedDate, displayedComponents: .date) {
                Text(title)
            }
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityLabel(title)
        }
    }

    private var hasDate: Binding<Bool> {
        Binding(
            get: { date != nil },
            set: { isOn in date = isOn ? (date ?? .now) : nil }
        )
    }

    private var unwrappedDate: Binding<Date> {
        Binding(
            get: { date ?? .now },
            set: { date = $0 }
        )
    }
}
