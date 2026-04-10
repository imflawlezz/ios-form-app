import Combine
import CoreData
import Foundation

@MainActor
final class CoreDataContactRepository: ObservableObject, ContactRepository {
    @Published private(set) var contacts: [Contact] = []

    private let stack: CoreDataStack
    private let context: NSManagedObjectContext

    init(stack: CoreDataStack? = nil) {
        let stack = stack ?? CoreDataStack()
        self.stack = stack
        self.context = stack.container.viewContext
        refresh()
    }

    func contact(withId id: UUID) -> Contact? {
        contacts.first { $0.id == id }
    }

    func add(_ contact: Contact) {
        let obj = CDContact(context: context)
        obj.apply(domain: contact)
        saveContext()
        refresh()
    }

    func update(_ contact: Contact) {
        guard let obj = fetchManagedContact(id: contact.id) else { return }
        obj.apply(domain: contact)
        saveContext()
        refresh()
    }

    func remove(_ contact: Contact) {
        guard let obj = fetchManagedContact(id: contact.id) else { return }
        context.delete(obj)
        saveContext()
        refresh()
    }

    func removeAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDContact")
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        delete.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(delete) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs], into: [context])
            }
        } catch {
            context.rollback()
        }
        refresh()
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
            let domain = Contact(
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
                doNotify: s.9,
                avatarData: nil
            )
            let obj = CDContact(context: context)
            obj.apply(domain: domain)
        }
        saveContext()
        refresh()
    }

    private func refresh() {
        let request: NSFetchRequest<CDContact> = CDContact.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "lastName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
            NSSortDescriptor(key: "firstName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
        ]
        do {
            let results = try context.fetch(request)
            contacts = results.map { $0.toDomain() }
        } catch {
            contacts = []
        }
    }

    private func fetchManagedContact(id: UUID) -> CDContact? {
        let request: NSFetchRequest<CDContact> = CDContact.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

}

private extension CDContact {
    func apply(domain: Contact) {
        id = domain.id
        firstName = domain.firstName
        lastName = domain.lastName
        birthdate = domain.birthdate
        genderRaw = domain.gender?.rawValue
        email = domain.email
        phone = domain.phone
        address = domain.address
        city = domain.city
        zip = domain.zip
        notes = domain.notes
        doNotify = domain.doNotify
        avatarData = domain.avatarData
    }

    func toDomain() -> Contact {
        Contact(
            id: id ?? UUID(),
            firstName: firstName ?? "",
            lastName: lastName ?? "",
            birthdate: birthdate,
            gender: genderRaw.flatMap(Gender.init(rawValue:)),
            email: email ?? "",
            phone: phone ?? "",
            address: address ?? "",
            city: city ?? "",
            zip: zip ?? "",
            notes: notes ?? "",
            doNotify: doNotify,
            avatarData: avatarData
        )
    }
}

