import Foundation

enum ContactListGrouping {
    static func sections(from contacts: [Contact]) -> [(letter: String, contacts: [Contact])] {
        let sorted = contacts.sorted { c1, c2 in
            let ln = c1.lastName.localizedCaseInsensitiveCompare(c2.lastName)
            if ln != .orderedSame { return ln == .orderedAscending }
            return c1.firstName.localizedCaseInsensitiveCompare(c2.firstName) == .orderedAscending
        }
        let grouped = Dictionary(grouping: sorted) { sectionLetter(for: $0) }
        return grouped.map { (letter: $0.key, contacts: $0.value) }.sorted { $0.letter < $1.letter }
    }

    private static func sectionLetter(for contact: Contact) -> String {
        let last = contact.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = contact.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameForLetter = last.isEmpty ? first : last
        guard let char = nameForLetter.uppercased().first else { return "#" }
        return char.isLetter ? String(char) : "#"
    }
}
