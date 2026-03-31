import Foundation

extension Contact {
    static func hasContent(_ string: String) -> Bool {
        !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

    var dialURL: URL? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let dialString = trimmed.filter { $0.isNumber || $0 == "+" }
        guard !dialString.isEmpty else { return nil }
        return URL(string: "tel:\(dialString)")
    }
}

