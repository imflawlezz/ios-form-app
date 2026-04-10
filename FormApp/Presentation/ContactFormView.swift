import PhotosUI
import SwiftUI
import UIKit

struct ContactFormView: View {
    @EnvironmentObject private var repository: ContactRepositoryImpl
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ContactFormViewModel
    @FocusState private var focusedField: ContactFormTextField?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCamera = false

    init(contact: Contact? = nil) {
        _viewModel = StateObject(wrappedValue: ContactFormViewModel(contact: contact))
    }

    var body: some View {
        Form {
            Section {
                HStack(alignment: .center, spacing: 6) {
                    ContactAvatarView(
                        contact: Contact(
                            id: viewModel.draftId,
                            firstName: viewModel.firstName,
                            lastName: viewModel.lastName,
                            birthdate: viewModel.birthdate,
                            gender: viewModel.gender,
                            email: viewModel.email,
                            phone: viewModel.phone,
                            address: viewModel.address,
                            city: viewModel.city,
                            zip: viewModel.zip,
                            notes: viewModel.notes,
                            doNotify: viewModel.doNotify,
                            avatarData: viewModel.avatarData
                        ),
                        size: viewModel.isEditing ? 88 : 76
                    )

                    Spacer(minLength: 0)

                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            PhotoIconActionButton(
                                systemImage: "photo.on.rectangle.angled",
                                tint: .accentColor,
                                fill: Color.accentColor.opacity(0.18)
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .accessibilityLabel("Choose photo")

                        Button {
                            isShowingCamera = true
                        } label: {
                            PhotoIconActionButton(
                                systemImage: "camera",
                                tint: .accentColor,
                                fill: Color.accentColor.opacity(0.18)
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .accessibilityLabel("Take photo")
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                        if viewModel.avatarData != nil {
                            Button(role: .destructive) {
                                viewModel.setAvatarData(nil)
                            } label: {
                                PhotoIconActionButton(
                                    systemImage: "trash",
                                    tint: .red,
                                    fill: Color.red.opacity(0.16)
                                )
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .accessibilityLabel("Remove photo")
                        }
                    }
                }
            } header: {
                Text("Photo")
            }

            Section {
                ContactFormFieldWithError(message: viewModel.visibleFirstNameError) {
                    TextField("First Name", text: $viewModel.firstName)
                        .textContentType(.givenName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .firstName)
                        .onSubmit { ContactFormTextField.firstName.advance(focus: $focusedField) }
                }

                ContactFormFieldWithError(message: viewModel.visibleLastNameError) {
                    TextField("Last Name", text: $viewModel.lastName)
                        .textContentType(.familyName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .lastName)
                        .onSubmit { ContactFormTextField.lastName.advance(focus: $focusedField) }
                }

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
                    ContactFormFieldWithError(message: viewModel.visibleBirthdateError) {
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
            } header: {
                Text("Personal Information")
            }
            Section {
                ContactFormFieldWithError(message: viewModel.visiblePhoneError) {
                    TextField("Phone", text: $viewModel.phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)
                }

                ContactFormFieldWithError(message: viewModel.visibleEmailError) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .onSubmit { ContactFormTextField.email.advance(focus: $focusedField) }
                }
            } header: {
                Text("Contact Information")
            }
            Section("Address") {
                ContactFormFieldWithError(message: viewModel.visibleAddressError) {
                    TextField("Address", text: $viewModel.address)
                        .textContentType(.streetAddressLine1)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .address)
                        .onSubmit { ContactFormTextField.address.advance(focus: $focusedField) }
                }

                ContactFormFieldWithError(message: viewModel.visibleCityError) {
                    TextField("City", text: $viewModel.city)
                        .textContentType(.addressCity)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .city)
                        .onSubmit { ContactFormTextField.city.advance(focus: $focusedField) }
                }

                ContactFormFieldWithError(message: viewModel.visibleZipError) {
                    TextField("Postal Code", text: $viewModel.zip)
                        .textContentType(.postalCode)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .zip)
                        .onSubmit { ContactFormTextField.zip.advance(focus: $focusedField) }
                }
            }
            Section {
                ContactFormFieldWithError(message: viewModel.visibleNotesError) {
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(1...3)
                        .focused($focusedField, equals: .notes)
                }

                Toggle("Receive notifications", isOn: $viewModel.doNotify)
            } header: {
                Text("Notes and Notifications")
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .onChange(of: viewModel.firstName) { _, _ in
            viewModel.noteFirstNameChanged()
        }
        .onChange(of: viewModel.phone) { _, _ in
            viewModel.notePhoneChanged()
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    if let jpeg = image.jpegData(compressionQuality: 0.85) {
                        await MainActor.run {
                            viewModel.setAvatarData(jpeg)
                        }
                    }
                }
                await MainActor.run {
                    selectedPhotoItem = nil
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraView(onCapture: { data in
                viewModel.setAvatarData(data)
                isShowingCamera = false
            })
            .ignoresSafeArea()
            .onDisappear {
                isShowingCamera = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if viewModel.commitSaveAttempt(using: repository) {
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
}

private struct PhotoIconActionButton: View {
    let systemImage: String
    let tint: Color
    let fill: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(fill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        .environmentObject(ContactRepositoryImpl())
    }
}
