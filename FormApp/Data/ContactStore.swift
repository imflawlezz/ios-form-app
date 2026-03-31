//
//  ContactStore.swift
//  FormApp
//

import Combine
import SwiftUI

@MainActor
final class ContactStore: ObservableObject, ContactRepository {
    @Published private(set) var contacts: [Contact] = []

    func contact(withId id: UUID) -> Contact? {
        contacts.first { $0.id == id }
    }

    var sortedSections: [(letter: String, contacts: [Contact])] {
        let sorted = contacts.sorted { c1, c2 in
            let ln = c1.lastName.localizedCaseInsensitiveCompare(c2.lastName)
            if ln != .orderedSame { return ln == .orderedAscending }
            return c1.firstName.localizedCaseInsensitiveCompare(c2.firstName) == .orderedAscending
        }
        let grouped = Dictionary(grouping: sorted) { $0.sectionLetter }
        return grouped.map { (letter: $0.key, contacts: $0.value) }.sorted { $0.letter < $1.letter }
    }

    func add(_ contact: Contact) {
        contacts.append(contact)
    }

    func remove(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
    }

    func remove(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }

    func removeAll() {
        contacts.removeAll()
    }

    func addSampleContacts() {
        let samples: [(String, String, Gender, String, String, String, String, String, String, Bool)] = [
            ("Alice", "Smith", .female, "alice@example.com", "+1 111 111 1111", "100 Oak St", "Boston", "02101", "Loves hiking", true),
            ("Bob", "Jones", .male, "bob@example.com", "+1 222 222 2222", "200 Pine Ave", "Seattle", "98101", "Developer", false),
            ("Carol", "Williams", .female, "carol@example.com", "+1 333 333 3333", "300 Elm Rd", "Denver", "80201", "Chef", true),
            ("David", "Brown", .male, "david@example.com", "+1 444 444 4444", "400 Maple Dr", "Austin", "73301", "Musician", true),
            ("Eve", "Davis", .female, "eve@example.com", "+1 555 555 5555", "500 Cedar Ln", "Portland", "97201", "Artist", false),
            ("Frank", "Miller", .male, "frank@example.com", "+1 666 666 6666", "600 Birch St", "Chicago", "60601", "Engineer", true),
            ("Grace", "Wilson", .female, "grace@example.com", "+1 777 777 7777", "700 Spruce Way", "Miami", "33101", "Teacher", true),
            ("Henry", "Taylor", .male, "henry@example.com", "+1 888 888 8888", "800 Ash Blvd", "Phoenix", "85001", "Designer", false),
            ("Ivy", "Anderson", .female, "ivy@example.com", "+1 999 999 9999", "900 Walnut Ct", "San Diego", "92101", "Writer", true),
            ("Jack", "Thomas", .male, "jack@example.com", "+1 000 000 0000", "10 Cherry Pl", "Atlanta", "30301", "Photographer", false),
        ]
        let calendar = Calendar.current
        let baseDate = calendar.date(byAdding: .year, value: -8, to: Date())!
        for (index, s) in samples.enumerated() {
            let birthdate = calendar.date(byAdding: .year, value: -10 - index, to: baseDate)
            contacts.append(Contact(
                firstName: s.0,
                lastName: s.1,
                birthdate: birthdate,
                gender: s.2,
                email: s.3,
                phone: s.4,
                address: s.5,
                city: s.6,
                zip: s.7,
                notes: s.8,
                doNotify: s.9
            ))
        }
    }

    func update(_ contact: Contact) {
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else { return }
        contacts[index] = contact
    }
}
