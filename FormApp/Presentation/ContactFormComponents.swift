import SwiftUI

struct ContactFormFieldWithError<Content: View>: View {
    let message: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

enum ContactFormTextField: Hashable {
    case firstName
    case lastName
    case phone
    case email
    case address
    case city
    case zip
    case notes

    private static let focusOrder: [ContactFormTextField] = [
        .firstName, .lastName, .phone, .email, .address, .city, .zip, .notes,
    ]

    func advance(focus: FocusState<ContactFormTextField?>.Binding) {
        advanceFocus(order: Self.focusOrder, current: self) { focus.wrappedValue = $0 }
    }
}
