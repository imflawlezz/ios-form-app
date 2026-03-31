import Foundation

extension Gender {
    var symbolName: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        }
    }
}

