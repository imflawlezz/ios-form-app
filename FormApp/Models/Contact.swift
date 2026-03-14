import Foundation

struct Contact: Identifiable {
    let id = UUID()

    var firstName: String
    var lastName: String

    var gender: Gender

    var email: String
    var phone: String

    var address: String
    var city: String
    var zip: String

    var notes: String
    var doNotify: Bool

    init(
        firstName: String,
        lastName: String,
        gender: Gender,
        email: String,
        phone: String,
        address: String,
        city: String,
        zip: String,
        notes: String,
        doNotify: Bool = false
    ) {
        self.firstName = firstName
        self.lastName = lastName
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
