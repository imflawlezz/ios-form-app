import SwiftUI

struct ContactAvatarView: View {
    let contact: Contact
    var size: CGFloat = 44

    var body: some View {
        let colors = contact.avatarGradientColors
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [colors.0, colors.1],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(contact.initials)
                .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
    }
}

#Preview {
    HStack {
        ContactAvatarView(
            contact: Contact(
                firstName: "Jane",
                lastName: "Doe",
                email: "j@example.com",
                phone: "+1 234",
                address: "",
                city: "",
                zip: "",
                notes: ""
            ),
            size: 56
        )
        ContactAvatarView(
            contact: Contact(
                firstName: "A",
                lastName: "B",
                email: "a@b.com",
                phone: "1",
                address: "",
                city: "",
                zip: "",
                notes: ""
            ),
            size: 44
        )
    }
    .padding()
}
