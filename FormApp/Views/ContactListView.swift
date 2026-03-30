//
//  ContactListView.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import SwiftUI
import UIKit

struct ContactListView: View {
    @EnvironmentObject private var store: ContactStore
    @State private var showDeleteAllConfirmation = false

    var body: some View {
        Group {
            if store.contacts.isEmpty {
                ContactListEmptyState()
            } else {
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
            }
        }
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

private struct ContactListRowTitle: View {
    let contact: Contact

    var body: some View {
        let first = contact.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = contact.lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        if !first.isEmpty && !last.isEmpty {
            Text("\(first) ") + Text(last).fontWeight(.bold)
        } else if !last.isEmpty {
            Text(last).fontWeight(.bold)
        } else if !first.isEmpty {
            Text(first).fontWeight(.bold)
        } else {
            Text(contact.phone.trimmingCharacters(in: .whitespacesAndNewlines))
                .fontWeight(.bold)
        }
    }
}

#Preview {
    NavigationStack {
        ContactListView()
            .environmentObject(ContactStore())
    }
}
