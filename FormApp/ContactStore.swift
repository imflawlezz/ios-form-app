//
//  ContactStore.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import Combine
import SwiftUI

@MainActor
final class ContactStore: ObservableObject {
    @Published private(set) var contacts: [Contact] = []

    func add(_ contact: Contact) {
        contacts.append(contact)
    }

    func remove(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
    }

    func remove(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }

    func update(_ contact: Contact) {
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else { return }
        contacts[index] = contact
    }
}
