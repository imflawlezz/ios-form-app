import SwiftUI

struct ContactListView: View {
    @EnvironmentObject private var repository: ContactRepositoryImpl
    @Environment(\.openURL) private var openURL
    @State private var showDeleteAllConfirmation = false
    @State private var contactPendingDeletion: Contact?
    @State private var contactToEdit: Contact?

    private var sortedSections: [(letter: String, contacts: [Contact])] {
        ContactListGrouping.sections(from: repository.contacts)
    }

    var body: some View {
        Group {
            if repository.contacts.isEmpty {
                ContactListEmptyState()
            } else {
                List {
                    ForEach(sortedSections, id: \.letter) { section in
                        Section {
                            ForEach(section.contacts) { contact in
                                NavigationLink {
                                    ContactDetailsView(contactId: contact.id)
                                } label: {
                                    ContactListRow(contact: contact)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: contact.dialURL != nil) {
                                    if let url = contact.dialURL {
                                        Button {
                                            openURL(url)
                                        } label: {
                                            Image(systemName: "phone.fill")
                                        }
                                        .tint(.green)
                                        .accessibilityLabel("Call")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        contactToEdit = contact
                                    } label: {
                                        Image(systemName: "pencil")
                                    }
                                    .tint(.indigo)
                                    .accessibilityLabel("Edit")

                                    Button(role: .destructive) {
                                        contactPendingDeletion = contact
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .accessibilityLabel("Delete")
                                }
                            }
                        } header: {
                            Text(section.letter)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button {
                        repository.addSampleContacts()
                    } label: {
                        Label("Add sample contacts", systemImage: "person.2.badge.plus")
                    }
                    Button(role: .destructive) {
                        guard !repository.contacts.isEmpty else {
                            return
                        }
                        showDeleteAllConfirmation = true
                    } label: {
                        Label("Delete all contacts", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel("More actions")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ContactFormView(contact: nil)
                } label: {
                    Image(systemName: "person.badge.plus")
                }
                .accessibilityLabel("Add contact")
            }
        }
        .confirmationDialog("Delete all contacts?", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible) {
            Button("Delete all", role: .destructive) {
                repository.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .confirmationDialog(
            "Delete contact?",
            isPresented: Binding(
                get: { contactPendingDeletion != nil },
                set: { if !$0 { contactPendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let contact = contactPendingDeletion {
                    repository.remove(contact)
                }
                contactPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                contactPendingDeletion = nil
            }
        } message: {
            if let contact = contactPendingDeletion {
                Text("Remove \(contact.displayName) from your contacts? This cannot be undone.")
            } else {
                Text("This contact will be removed. This cannot be undone.")
            }
        }
        .sheet(item: $contactToEdit) { contact in
            NavigationStack {
                ContactFormView(contact: contact)
                    .environmentObject(repository)
            }
        }
    }
}

private struct ContactListEmptyState: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 48)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.18))
                        .frame(width: 88, height: 88)
                        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                        .symbolRenderingMode(.hierarchical)
                        .symbolEffect(.pulse, options: .repeating, isActive: true)
                }

                Text("No contacts yet")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                Text("Add people to see them listed here and keep their details in one place.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer(minLength: 32)

            NavigationLink {
                ContactFormView(contact: nil)
            } label: {
                Text("Add contact")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

private struct ContactListRow: View {
    let contact: Contact

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ContactAvatarView(contact: contact, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                ContactListRowTitle(contact: contact)
                    .foregroundStyle(.primary)
                Text(contact.phoneCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ContactListRowTitle: View {
    let contact: Contact

    var body: some View {
        let first = contact.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = contact.lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        if !first.isEmpty && !last.isEmpty {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(first) ")
                Text(last).fontWeight(.bold)
            }
        } else if !last.isEmpty {
            Text(last).fontWeight(.bold)
        } else if !first.isEmpty {
            Text(first).fontWeight(.bold)
        } else {
            Text(contact.phoneCaption)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    NavigationStack {
        ContactListView()
            .environmentObject(ContactRepositoryImpl())
    }
}
