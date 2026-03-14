//
//  ContactFormView.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import SwiftUI

struct ContactFormView: View {
    @EnvironmentObject private var store: ContactStore
    @Environment(\.dismiss) private var dismiss

    let contact: Contact?

    @State private var firstName: String
    @State private var lastName: String
    @State private var gender: Gender
    @State private var email: String
    @State private var phone: String
    @State private var address: String
    @State private var city: String
    @State private var zip: String
    @State private var notes: String
    @State private var doNotify: Bool
    @State private var birthdate: Date
    @State private var showValidationAlert = false

    init(contact: Contact? = nil) {
        self.contact = contact
        _firstName = State(initialValue: contact?.firstName ?? "")
        _lastName = State(initialValue: contact?.lastName ?? "")
        _gender = State(initialValue: contact?.gender ?? Gender.allCases.first!)
        _email = State(initialValue: contact?.email ?? "")
        _phone = State(initialValue: contact?.phone ?? "")
        _address = State(initialValue: contact?.address ?? "")
        _city = State(initialValue: contact?.city ?? "")
        _zip = State(initialValue: contact?.zip ?? "")
        _notes = State(initialValue: contact?.notes ?? "")
        _doNotify = State(initialValue: contact?.doNotify ?? false)
        _birthdate = State(initialValue: contact?.birthdate ?? Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date())
    }

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                TextField("Last Name", text: $lastName)
                    .textContentType(.familyName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases) { g in
                        Text(g.rawValue).tag(g)
                    }
                }
            }
            Section("Contact Information") {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .submitLabel(.done)
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
                    .submitLabel(.done)
            }
            Section("Address") {
                TextField("Address", text: $address)
                    .textContentType(.streetAddressLine1)
                    .submitLabel(.done)
                TextField("City", text: $city)
                    .textContentType(.addressCity)
                    .submitLabel(.done)
                TextField("Postal Code", text: $zip)
                    .textContentType(.postalCode)
                    .submitLabel(.done)
            }
            Section("Notes and Notifications") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(1...3)
                Toggle("Receive notifications", isOn: $doNotify)
            }
        }
        .navigationTitle(contact != nil ? "Edit contact" : "New contact")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onSubmit { dismissKeyboard() }
        .dismissKeyboardOnTap()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let phoneTrimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard Contact.hasContent(first), Contact.hasContent(phoneTrimmed) else {
                        showValidationAlert = true
                        return
                    }
                    let savedContact = Contact(
                        id: contact?.id ?? UUID(),
                        firstName: firstName,
                        lastName: lastName,
                        birthdate: birthdate,
                        gender: gender,
                        email: email,
                        phone: phone,
                        address: address,
                        city: city,
                        zip: zip,
                        notes: notes,
                        doNotify: doNotify
                    )
                    if contact != nil {
                        store.update(savedContact)
                    } else {
                        store.add(savedContact)
                    }
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
                .accessibilityLabel("Save")
            }
        }
        .alert("Missing required fields", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("First name and phone are required.")
        }
    }
}

#Preview {
    NavigationStack {
        ContactFormView(contact: Contact(
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
