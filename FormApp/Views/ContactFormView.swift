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

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var gender = Gender.allCases.first!
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var notes = ""
    @State private var doNotify = false

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                TextField("Last Name", text: $lastName)
                    .textContentType(.familyName)
                    .textInputAutocapitalization(.words)
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
            }
            Section("Contact Information") {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
            }
            Section("Address") {
                TextField("Address", text: $address)
                    .textContentType(.streetAddressLine1)
                TextField("City", text: $city)
                    .textContentType(.addressCity)
                TextField("Zip", text: $zip)
                    .textContentType(.postalCode)
            }
            Section("Notes and Notifications") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(1...3)
                Toggle("Receive notifications", isOn: $doNotify)
            }
        }

        .navigationTitle("New contact")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .confirm) {
                    let contact = Contact(
                        firstName: firstName,
                        lastName: lastName,
                        gender: gender,
                        email: email,
                        phone: phone,
                        address: address,
                        city: city,
                        zip: zip,
                        notes: notes,
                        doNotify: doNotify
                    )
                    store.add(contact)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

#Preview {
    ContactFormView()
        .environmentObject(ContactStore())
}
