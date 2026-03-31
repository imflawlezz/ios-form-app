//
//  ContactFormFieldWithError.swift
//  FormApp
//

import SwiftUI

struct ContactFormFieldWithError<Content: View>: View {
    let message: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
