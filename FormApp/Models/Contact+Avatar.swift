//
//  Contact+Avatar.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 31/03/2026.
//

import SwiftUI

extension Contact {
    var phoneCaption: String {
        phone.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var avatarGradientColors: (Color, Color) {
        let index = Self.stablePaletteIndex(for: id)
        return Self.avatarGradientPalette[index]
    }

    private static let avatarGradientPalette: [(Color, Color)] = [
        (Color(red: 0.25, green: 0.45, blue: 0.92), Color(red: 0.45, green: 0.75, blue: 0.98)),
        (Color(red: 0.55, green: 0.32, blue: 0.88), Color(red: 0.78, green: 0.48, blue: 0.95)),
        (Color(red: 0.95, green: 0.38, blue: 0.48), Color(red: 1.0, green: 0.62, blue: 0.45)),
        (Color(red: 0.18, green: 0.62, blue: 0.55), Color(red: 0.35, green: 0.82, blue: 0.65)),
        (Color(red: 0.92, green: 0.52, blue: 0.22), Color(red: 0.98, green: 0.72, blue: 0.35)),
        (Color(red: 0.35, green: 0.38, blue: 0.85), Color(red: 0.55, green: 0.58, blue: 0.98)),
        (Color(red: 0.82, green: 0.28, blue: 0.52), Color(red: 0.95, green: 0.45, blue: 0.62)),
        (Color(red: 0.22, green: 0.55, blue: 0.38), Color(red: 0.42, green: 0.75, blue: 0.48)),
    ]

    private static func stablePaletteIndex(for id: UUID) -> Int {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in id.uuidString.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return Int(hash % UInt64(avatarGradientPalette.count))
    }
}
