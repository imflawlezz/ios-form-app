import Foundation

enum ContactSearch {
    static func filter(contacts: [Contact], query: String) -> [Contact] {
        let needle = normalize(query)
        guard !needle.isEmpty else { return contacts }
        return contacts.filter { haystack(for: $0).contains(needle) }
    }

    private static func normalize(_ string: String) -> String {
        string
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func haystack(for contact: Contact) -> String {
        var parts: [String] = []
        parts.append(contact.firstName)
        parts.append(contact.lastName)
        parts.append(contact.displayName)
        parts.append(contact.initials)
        parts.append(contact.phone)
        parts.append(contact.email)
        parts.append(contact.address)
        parts.append(contact.city)
        parts.append(contact.zip)
        parts.append(contact.notes)
        if let gender = contact.gender?.rawValue { parts.append(gender) }
        if let birth = contact.birthdateFormattedWithAge { parts.append(birth) }
        if let fullAddress = contact.fullAddress { parts.append(fullAddress) }
        if contact.doNotify { parts.append("notifications enabled") }
        return normalize(parts.joined(separator: " "))
    }
}

