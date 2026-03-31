//
//  ContactFormViewModel.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import Combine
import Foundation

@MainActor
final class ContactFormViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var gender: Gender?
    @Published var email: String
    @Published var phone: String
    @Published var address: String
    @Published var city: String
    @Published var zip: String
    @Published var notes: String
    @Published var doNotify: Bool
    @Published var birthdate: Date?

    @Published private(set) var showValidationAfterFailedSave = false
    @Published private(set) var firstNameHadNonEmptyInput = false
    @Published private(set) var phoneHadNonEmptyInput = false

    private let existingContactId: UUID?

    init(contact: Contact? = nil) {
        existingContactId = contact?.id
        firstName = contact?.firstName ?? ""
        lastName = contact?.lastName ?? ""
        gender = contact?.gender
        email = contact?.email ?? ""
        phone = contact?.phone ?? ""
        address = contact?.address ?? ""
        city = contact?.city ?? ""
        zip = contact?.zip ?? ""
        notes = contact?.notes ?? ""
        doNotify = contact?.doNotify ?? false
        birthdate = contact?.birthdate

        if let contact {
            if Contact.hasContent(contact.firstName) { firstNameHadNonEmptyInput = true }
            if Contact.hasContent(contact.phone) { phoneHadNonEmptyInput = true }
        }
    }

    var isEditing: Bool { existingContactId != nil }

    var navigationTitle: String { isEditing ? "Edit contact" : "New contact" }

    var isFormValid: Bool {
        ContactFormValidation.isFormValid(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            address: address,
            city: city,
            zip: zip,
            notes: notes,
            birthdate: birthdate
        )
    }

    private var firstNameError: String? { ContactFormValidation.firstNameError(firstName) }
    private var lastNameError: String? { ContactFormValidation.lastNameError(lastName) }
    private var phoneError: String? { ContactFormValidation.phoneError(phone: phone) }
    private var emailError: String? { ContactFormValidation.emailError(email) }
    private var birthdateError: String? { ContactFormValidation.birthdateError(birthdate) }
    private var addressError: String? { ContactFormValidation.addressError(address) }
    private var cityError: String? { ContactFormValidation.cityError(city) }
    private var zipError: String? { ContactFormValidation.zipError(zip) }
    private var notesError: String? { ContactFormValidation.notesError(notes) }

    var visibleFirstNameError: String? {
        visibleRequiredField(firstNameError, hadNonEmptyInput: firstNameHadNonEmptyInput)
    }

    var visibleLastNameError: String? {
        visibleLengthField(lastNameError, isOverLimit: lastName.count > 200)
    }

    var visiblePhoneError: String? {
        visibleRequiredField(phoneError, hadNonEmptyInput: phoneHadNonEmptyInput)
    }

    var visibleEmailError: String? {
        guard let message = emailError else { return nil }
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if showValidationAfterFailedSave || !trimmed.isEmpty { return message }
        return nil
    }

    var visibleBirthdateError: String? { birthdateError }

    var visibleAddressError: String? {
        let t = address.trimmingCharacters(in: .whitespacesAndNewlines)
        return visibleLengthField(addressError, isOverLimit: t.count > 300)
    }

    var visibleCityError: String? {
        let t = city.trimmingCharacters(in: .whitespacesAndNewlines)
        return visibleLengthField(cityError, isOverLimit: t.count > 100)
    }

    var visibleZipError: String? {
        guard let message = zipError else { return nil }
        let trimmed = zip.trimmingCharacters(in: .whitespacesAndNewlines)
        if showValidationAfterFailedSave || !trimmed.isEmpty { return message }
        return nil
    }

    var visibleNotesError: String? {
        visibleLengthField(notesError, isOverLimit: notes.count > ContactFormValidation.notesMaxLength)
    }

    private func visibleRequiredField(_ message: String?, hadNonEmptyInput: Bool) -> String? {
        guard let message else { return nil }
        if showValidationAfterFailedSave || hadNonEmptyInput { return message }
        return nil
    }

    private func visibleLengthField(_ message: String?, isOverLimit: Bool) -> String? {
        guard let message else { return nil }
        if showValidationAfterFailedSave || isOverLimit { return message }
        return nil
    }


    func noteFirstNameChanged() {
        if Contact.hasContent(firstName) { firstNameHadNonEmptyInput = true }
    }

    func notePhoneChanged() {
        if Contact.hasContent(phone) { phoneHadNonEmptyInput = true }
    }

    @discardableResult
    func commitSaveAttempt(using repository: ContactRepository) -> Bool {
        if isFormValid {
            return save(using: repository)
        }
        showValidationAfterFailedSave = true
        return false
    }

    private func save(using repository: ContactRepository) -> Bool {
        let saved = Contact(
            id: existingContactId ?? UUID(),
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

        if isEditing {
            repository.update(saved)
        } else {
            repository.add(saved)
        }
        return true
    }
}
