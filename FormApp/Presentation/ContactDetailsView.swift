import SwiftUI

struct ContactDetailsView: View {
    @EnvironmentObject private var repository: ContactRepositoryImpl
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showDeleteConfirmation = false
    let contactId: UUID

    private var contact: Contact? {
        repository.contact(withId: contactId)
    }

    var body: some View {
        Group {
            if let contact {
                detailsList(for: contact)
            } else {
                ContentUnavailableView("Contact not found", systemImage: "person.crop.circle.badge.xmark")
                    .onAppear { dismiss() }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func detailsList(for contact: Contact) -> some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ContactAvatarView(contact: contact, size: 100)

                    Text(contact.displayName)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)

                    if let url = contact.dialURL {
                        Button {
                            openURL(url)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                Text("Call")
                            }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 12)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(.green)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Call")
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                .listRowBackground(Color.clear)
            }

            if contact.gender != nil || contact.birthdate != nil {
                Section("About") {
                    if let gender = contact.gender {
                        DetailRow(icon: gender.symbolName, value: gender.rawValue)
                    }
                    if let birthdateText = contact.birthdateFormattedWithAge {
                        DetailRow(icon: "calendar", value: birthdateText)
                    }
                }
            }

            if Contact.hasContent(contact.email) || Contact.hasContent(contact.phone) {
                Section("Contact") {
                    if Contact.hasContent(contact.phone) {
                        DetailRow(icon: "phone.fill", value: contact.phone)
                    }
                    if Contact.hasContent(contact.email) {
                        DetailRow(icon: "envelope.fill", value: contact.email)
                    }
                }
            }

            if let fullAddress = contact.fullAddress {
                Section("Address") {
                    DetailRow(icon: "building.2.fill", value: fullAddress)
                }
            }

            if Contact.hasContent(contact.notes) {
                Section("Notes") {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "note.text")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(width: 24, alignment: .center)
                        Text(contact.notes)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }

            if contact.doNotify {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(.secondary)
                        Text("Notifications enabled")
                            .foregroundStyle(.secondary)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(12)
        .navigationTitle(contact.displayName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ContactFormView(contact: contact)
                } label: {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
        }
        .confirmationDialog("Delete contact?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                repository.remove(contact)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Remove \(contact.displayName) from your contacts? This cannot be undone.")
        }
    }
}

private struct DetailRow: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)
            Text(value)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
    }
}

#Preview {
    let repository = ContactRepositoryImpl()
    let sample = Contact(
        firstName: "Jane",
        lastName: "Doe",
        birthdate: Calendar.current.date(byAdding: .year, value: -30, to: Date()),
        gender: .female,
        email: "jane@example.com",
        phone: "+1 234 567 8900",
        address: "123 Main St",
        city: "New York",
        zip: "10001",
        notes: "Sample note"
    )
    repository.add(sample)

    return NavigationStack {
        ContactDetailsView(contactId: sample.id)
            .environmentObject(repository)
    }
}
