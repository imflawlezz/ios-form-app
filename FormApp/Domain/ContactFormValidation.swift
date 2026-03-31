//
//  ContactFormValidation.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 31/03/2026.

import Foundation

enum ContactFormValidation {
    static let notesMaxLength = 500

    static func firstNameError(_ raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "Add a first name." }
        if t.count > 200 { return "Keep it under 200 characters." }
        return nil
    }

    static func lastNameError(_ raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count > 200 { return "Keep it under 200 characters." }
        return nil
    }

    static func phoneError(phone: String) -> String? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "Add a phone number." }
        if !phoneCharactersValid(phone) {
            return "Stick to digits, spaces, and + ( ) - ."
        }
        if !phoneHasDialableDigits(trimmed) {
            return "Include at least one digit."
        }
        if !phoneLengthValid(trimmed) {
            return "Shorten this a bit (32 characters max)."
        }
        return nil
    }

    static func emailError(_ raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        if !isValidEmailFormat(t) {
            return "That doesn't look like an email address."
        }
        return nil
    }

    static func birthdateError(_ date: Date?) -> String? {
        guard let birth = date else { return nil }
        let cal = Calendar.current
        if cal.startOfDay(for: birth) > cal.startOfDay(for: Date()) {
            return "Birthday can't be in the future."
        }
        return nil
    }

    static func addressError(_ raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count > 300 { return "Keep the address under 300 characters." }
        return nil
    }

    static func cityError(_ raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count > 100 { return "Keep the city under 100 characters." }
        return nil
    }

    static func zipError(_ raw: String) -> String? {
        if isValidPostalCodeOptional(raw) { return nil }
        return "Use letters, numbers, spaces, or hyphens—up to 16 characters."
    }

    static func notesError(_ raw: String) -> String? {
        if raw.count <= notesMaxLength { return nil }
        return "You've hit the \(notesMaxLength)-character limit."
    }

    static func isValidEmailFormat(_ string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        if trimmed.count > 254 { return false }
        return trimmed.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil
    }

    static func phoneHasDialableDigits(_ phone: String) -> Bool {
        phone.contains { $0.isNumber }
    }

    static func phoneLengthValid(_ phone: String) -> Bool {
        phone.trimmingCharacters(in: .whitespacesAndNewlines).count <= 32
    }

    static func phoneCharactersValid(_ phone: String) -> Bool {
        phone.allSatisfy { c in
            c.isNumber || c.isWhitespace || "+()-.".contains(c)
        }
    }

    static func isValidPostalCodeOptional(_ zip: String) -> Bool {
        let t = zip.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return true }
        if t.count > 16 { return false }
        return t.allSatisfy { $0.isLetter || $0.isNumber || $0.isWhitespace || $0 == "-" }
    }

    static func isFormValid(
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        address: String,
        city: String,
        zip: String,
        notes: String,
        birthdate: Date?
    ) -> Bool {
        firstNameError(firstName) == nil
            && lastNameError(lastName) == nil
            && phoneError(phone: phone) == nil
            && emailError(email) == nil
            && birthdateError(birthdate) == nil
            && addressError(address) == nil
            && cityError(city) == nil
            && zipError(zip) == nil
            && notesError(notes) == nil
    }
}
