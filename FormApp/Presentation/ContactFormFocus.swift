//
//  ContactFormFocus.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 31/03/2026.
//

import SwiftUI

enum ContactFormTextField: Hashable {
    case firstName, lastName, phone, email, address, city, zip, notes

    static let focusOrder: [ContactFormTextField] = [
        .firstName, .lastName, .phone, .email, .address, .city, .zip, .notes
    ]

    func advance(focus: FocusState<ContactFormTextField?>.Binding) {
        advanceFocus(order: Self.focusOrder, current: self) { focus.wrappedValue = $0 }
    }
}