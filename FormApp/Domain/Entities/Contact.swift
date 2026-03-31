import Foundation

struct Contact: Identifiable, Codable {
    let id: UUID

    var firstName: String
    var lastName: String
    var birthdate: Date?

    var gender: Gender?

    var email: String
    var phone: String

    var address: String
    var city: String
    var zip: String

    var notes: String
    var doNotify: Bool

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        birthdate: Date? = nil,
        gender: Gender? = nil,
        email: String,
        phone: String,
        address: String,
        city: String,
        zip: String,
        notes: String,
        doNotify: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthdate = birthdate
        self.gender = gender
        self.email = email
        self.phone = phone
        self.address = address
        self.city = city
        self.zip = zip
        self.notes = notes
        self.doNotify = doNotify
    }
}
