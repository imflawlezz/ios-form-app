enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"

    var id: String { self.rawValue }

    var symbolName: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        }
    }
}