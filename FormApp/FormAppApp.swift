//
//  FormAppApp.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import SwiftUI

@main
struct FormAppApp: App {
    @StateObject private var contactRepository = CoreDataContactRepository()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContactListView()
            }
            .environmentObject(contactRepository)
        }
    }
}
