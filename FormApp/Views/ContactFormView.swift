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

    @StateObject private var viewModel: ContactFormViewModel

    init(contact: Contact? = nil) {
        _viewModel = StateObject(wrappedValue: ContactFormViewModel(contact: contact))
    }

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $viewModel.firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                TextField("Last Name", text: $viewModel.lastName)
                    .textContentType(.familyName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                Picker("Gender", selection: $viewModel.gender) {
                    Text("Not specified").tag(Optional<Gender>.none)
                    ForEach(Gender.allCases) { g in
                        Text(g.rawValue).tag(Optional(g))
                    }
                }
                if viewModel.birthdate == nil {
                    Button {
                        viewModel.birthdate = Date()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                            Text("Add birthdate")
                        }
                    }
                } else {
                    HStack {
                        DatePicker(
                            "Birthdate",
                            selection: Binding(
                                get: { viewModel.birthdate ?? Date() },
                                set: { viewModel.birthdate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        Button {
                            viewModel.birthdate = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Remove birthdate")
                    }
                }
            }
            Section("Contact Information") {
                TextField("Phone", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .submitLabel(.done)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .submitLabel(.done)
            }
            Section("Address") {
                TextField("Address", text: $viewModel.address)
                    .textContentType(.streetAddressLine1)
                    .submitLabel(.done)
                TextField("City", text: $viewModel.city)
                    .textContentType(.addressCity)
                    .submitLabel(.done)
                TextField("Postal Code", text: $viewModel.zip)
                    .textContentType(.postalCode)
                    .submitLabel(.done)
            }
            Section("Notes and Notifications") {
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(1...3)
                Toggle("Receive notifications", isOn: $viewModel.doNotify)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onSubmit { dismissKeyboard() }
        .dismissKeyboardOnTap()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if viewModel.save(using: store) {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Save")
            }
        }
        .alert("Missing required fields", isPresented: $viewModel.showValidationAlert) {
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
