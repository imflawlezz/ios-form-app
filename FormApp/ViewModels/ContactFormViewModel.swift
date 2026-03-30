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
    @Published var showValidationAlert = false

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
    }

    var isEditing: Bool { existingContactId != nil }

    var navigationTitle: String { isEditing ? "Edit contact" : "New contact" }

    func save(using store: ContactStore) -> Bool {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneTrimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Contact.hasContent(first), Contact.hasContent(phoneTrimmed) else {
            showValidationAlert = true
            return false
        }

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
            store.update(saved)
        } else {
            store.add(saved)
        }
        return true
    }
}
