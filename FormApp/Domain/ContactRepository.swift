import Foundation

@MainActor
protocol ContactRepository: AnyObject {
    var contacts: [Contact] { get }

    func contact(withId id: UUID) -> Contact?

    func add(_ contact: Contact)
    func update(_ contact: Contact)
    func remove(_ contact: Contact)
    func removeAll()
    func addSampleContacts()
}
