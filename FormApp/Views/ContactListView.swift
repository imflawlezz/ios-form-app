//
//  ContactListView.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import SwiftUI

struct ContactListView: View {
    @EnvironmentObject private var store: ContactStore
    @State private var showDeleteAllConfirmation = false

    var body: some View {
        List {
            ForEach(store.sortedSections, id: \.letter) { section in
                Section {
                    ForEach(section.contacts) { contact in
                        NavigationLink {
                            ContactDetailsView(contact: contact)
                        } label: {
                            ContactListRowTitle(contact: contact)
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
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button {
                        store.addSampleContacts()
                    } label: {
                        Label("Add sample contacts", systemImage: "person.2.badge.plus")
                    }
                    Button(role: .destructive) {
                        guard !store.contacts.isEmpty else {
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
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add contact")
            }
        }
        .confirmationDialog("Delete all contacts?", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible) {
            Button("Delete all", role: .destructive) {
                store.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }
}

private struct ContactListRowTitle: View {
    let contact: Contact

    var body: some View {
        let first = contact.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = contact.lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        if first.isEmpty && last.isEmpty {
            Text("Contact")
        } else if last.isEmpty {
            Text(first).fontWeight(.bold)
        } else if first.isEmpty {
            Text(last).fontWeight(.bold)
        } else {
            Text("\(first) ") + Text(last).fontWeight(.bold)
        }
    }
}

#Preview {
    NavigationStack {
        ContactListView()
            .environmentObject(ContactStore())
    }
}
