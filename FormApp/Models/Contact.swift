import Foundation

struct Contact: Identifiable {
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

    var displayName: String {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        return [first, last].filter { !$0.isEmpty }.joined(separator: " ")
            .isEmpty ? "Contact" : [first, last].joined(separator: " ")
    }

    var initials: String {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        return (first + last).uppercased().isEmpty ? "?" : (first + last).uppercased()
    }

    var sectionLetter: String {
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameForLetter = last.isEmpty ? first : last
        guard let char = nameForLetter.uppercased().first else { return "#" }
        return char.isLetter ? String(char) : "#"
    }

    var birthdateFormattedWithAge: String? {
        guard let birthdate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let years = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year ?? 0
        return "\(formatter.string(from: birthdate)) (\(years) \(years == 1 ? "year" : "years"))"
    }

    var fullAddress: String? {
        let street = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let cityTrimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let zipTrimmed = zip.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = [street, cityTrimmed].filter { !$0.isEmpty }
        let line = parts.joined(separator: ", ")
        if line.isEmpty && zipTrimmed.isEmpty { return nil }
        return zipTrimmed.isEmpty ? line : (line.isEmpty ? zipTrimmed : "\(line) \(zipTrimmed)")
    }

    static func hasContent(_ string: String) -> Bool {
        !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
