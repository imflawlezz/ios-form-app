import SwiftUI

struct ContactListView: View {
    @EnvironmentObject private var repository: ContactRepositoryImpl
    @Environment(\.openURL) private var openURL
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.isSearching) private var isSearching
    @State private var showDeleteAllConfirmation = false
    @State private var contactPendingDeletion: Contact?
    @State private var contactToEdit: Contact?
    @State private var searchText = ""

    private var sortedSections: [(letter: String, contacts: [Contact])] {
        ContactListGrouping.sections(from: filteredContacts)
    }

    private var filteredContacts: [Contact] {
        ContactSearch.filter(contacts: repository.contacts, query: searchText)
    }

    var body: some View {
        Group {
            if repository.contacts.isEmpty {
                ContactListEmptyState()
            } else {
                Group {
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && filteredContacts.isEmpty {
                        ContentUnavailableView("No matches", systemImage: "magnifyingglass")
                    } else {
                        List {
                            ForEach(sortedSections, id: \.letter) { section in
                                Section {
                                    ForEach(section.contacts) { contact in
                                        ContactListItem(
                                            contact: contact,
                                            openURL: openURL,
                                            onEdit: { contactToEdit = contact },
                                            onRequestDelete: { contactPendingDeletion = contact },
                                            isDeleteDialogPresented: Binding(
                                                get: { contactPendingDeletion?.id == contact.id },
                                                set: { if !$0 { contactPendingDeletion = nil } }
                                            ),
                                            onConfirmDelete: {
                                                repository.remove(contact)
                                                contactPendingDeletion = nil
                                            }
                                        )
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
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search contacts")
                .onSubmit(of: .search) {
                    dismissKeyboard()
                }
                .onChange(of: searchText) { oldValue, newValue in
                    let oldTrimmed = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    let newTrimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard isSearching, !oldTrimmed.isEmpty, newTrimmed.isEmpty else { return }
                    DispatchQueue.main.async {
                        dismissSearch()
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
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
                    .tint(.red)
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel("More actions")
                .confirmDeleteAllContacts(isPresented: $showDeleteAllConfirmation) {
                    repository.removeAll()
                }
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
        .sheet(item: $contactToEdit) { contact in
            NavigationStack {
                ContactFormView(contact: contact)
                    .environmentObject(repository)
            }
        }
    }
}

private struct ContactListItem: View {
    let contact: Contact
    let openURL: OpenURLAction
    let onEdit: () -> Void
    let onRequestDelete: () -> Void
    let isDeleteDialogPresented: Binding<Bool>
    let onConfirmDelete: () -> Void

    var body: some View {
        NavigationLink {
            ContactDetailsView(contactId: contact.id)
        } label: {
            ContactListRow(contact: contact)
        }
        .contextMenu {
            if let url = contact.dialURL {
                Button {
                    openURL(url)
                } label: {
                    Label("Call", systemImage: "phone.fill")
                }
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onRequestDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } preview: {
            ContactContextPreviewCard(contact: contact)
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
                onEdit()
            } label: {
                Image(systemName: "pencil")
            }
            .tint(.indigo)
            .accessibilityLabel("Edit")

            Button {
                onRequestDelete()
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            .accessibilityLabel("Delete")
        }
        .confirmDeleteContact(
            isPresented: isDeleteDialogPresented,
            contactName: contact.displayName
        ) {
            onConfirmDelete()
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
