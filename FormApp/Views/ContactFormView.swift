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
            Section {
                fieldBlock {
                    TextField("First Name", text: $viewModel.firstName)
                        .textContentType(.givenName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                } error: { viewModel.visibleFirstNameError }

                fieldBlock {
                    TextField("Last Name", text: $viewModel.lastName)
                        .textContentType(.familyName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                } error: { viewModel.visibleLastNameError }

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
                    VStack(alignment: .leading, spacing: 4) {
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
                        InlineFieldError(message: viewModel.visibleBirthdateError)
                    }
                }
            } header: {
                Text("Personal Information")
            }
            Section {
                fieldBlock {
                    TextField("Phone", text: $viewModel.phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .submitLabel(.done)
                } error: { viewModel.visiblePhoneError }

                fieldBlock {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                } error: { viewModel.visibleEmailError }
            } header: {
                Text("Contact Information")
            }
            Section("Address") {
                fieldBlock {
                    TextField("Address", text: $viewModel.address)
                        .textContentType(.streetAddressLine1)
                        .submitLabel(.done)
                } error: { viewModel.visibleAddressError }

                fieldBlock {
                    TextField("City", text: $viewModel.city)
                        .textContentType(.addressCity)
                        .submitLabel(.done)
                } error: { viewModel.visibleCityError }

                fieldBlock {
                    TextField("Postal Code", text: $viewModel.zip)
                        .textContentType(.postalCode)
                        .submitLabel(.done)
                } error: { viewModel.visibleZipError }
            }
            Section {
                fieldBlock {
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(1...3)
                } error: { viewModel.visibleNotesError }

                Toggle("Receive notifications", isOn: $viewModel.doNotify)
            } header: {
                Text("Notes and Notifications")
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onSubmit { dismissKeyboard() }
        .dismissKeyboardOnTap()
        .onChange(of: viewModel.firstName) { _, _ in
            viewModel.noteFirstNameChanged()
        }
        .onChange(of: viewModel.phone) { _, _ in
            viewModel.notePhoneChanged()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if viewModel.commitSaveAttempt(using: store) {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Save")
            }
        }
    }

    @ViewBuilder
    private func fieldBlock<Content: View>(
        @ViewBuilder content: () -> Content,
        error: @escaping () -> String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
            InlineFieldError(message: error())
        }
    }
}

private struct InlineFieldError: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
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
