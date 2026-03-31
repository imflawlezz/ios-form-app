import SwiftUI

struct ContactContextPreviewCard: View {
    let contact: Contact

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                groupedDetails
            }
            .padding(16)
        }
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ContactAvatarView(contact: contact, size: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var groupedDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            if contact.gender != nil || contact.birthdate != nil {
                group {
                    VStack(alignment: .leading, spacing: 8) {
                        if let gender = contact.gender {
                            row(icon: gender.symbolName, value: gender.rawValue)
                        }
                        if let birth = contact.birthdateFormattedWithAge {
                            row(icon: "calendar", value: birth)
                        }
                    }
                }
            }

            if Contact.hasContent(contact.phone) || Contact.hasContent(contact.email) {
                group {
                    VStack(alignment: .leading, spacing: 8) {
                        if Contact.hasContent(contact.phone) {
                            row(icon: "phone.fill", value: contact.phone.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        if Contact.hasContent(contact.email) {
                            row(icon: "envelope.fill", value: contact.email.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                }
            }

            if let address = contact.fullAddress {
                group {
                    row(icon: "building.2.fill", value: address)
                }
            }

            if Contact.hasContent(contact.notes) || contact.doNotify {
                group {
                    VStack(alignment: .leading, spacing: 8) {
                        if Contact.hasContent(contact.notes) {
                            row(icon: "note.text", value: contact.notes)
                        }
                        if contact.doNotify {
                            row(icon: "bell.badge.fill", value: "Enabled")
                        }
                    }
                }
            }
        }
    }

    private func group<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .background(.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func row(icon: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .center)

            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContactContextPreviewCard(contact: Contact(
        firstName: "Jane",
        lastName: "Doe",
        birthdate: Calendar.current.date(byAdding: .year, value: -30, to: Date()),
        gender: .female,
        email: "jane@example.com",
        phone: "+1 234 567 8900",
        address: "123 Main St",
        city: "New York",
        zip: "10001",
        notes: "Sample note",
        doNotify: true
    ))
}

