import Foundation

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "Male"
    case female = "Female"

    var id: String { self.rawValue }
}
