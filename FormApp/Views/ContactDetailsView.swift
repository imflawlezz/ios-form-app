//
//  ContactDetailsView.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import SwiftUI

struct ContactDetailsView: View {
    @EnvironmentObject private var store: ContactStore
    @Environment(\.dismiss) private var dismiss
    let contact: Contact

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.secondary.opacity(0.25))
                            .frame(width: 100, height: 100)
                        Text(contact.initials)
                            .font(.title.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    Text(contact.displayName)
                        .font(.title2.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
                .listRowBackground(Color.clear)
            }

            if contact.gender != nil || contact.birthdate != nil {
                Section("About") {
                    if let gender = contact.gender {
                        DetailRow(icon: "person.fill", value: gender.rawValue)
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
        .navigationTitle(contact.displayName)
        .navigationBarTitleDisplayMode(.inline)
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
                    store.remove(contact)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
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
    NavigationStack {
        ContactDetailsView(contact: Contact(
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
        ))
        .environmentObject(ContactStore())
    }
}
