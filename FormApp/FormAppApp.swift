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
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var awayTimeTracker = AwayTimeTracker()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContactListView()
            }
            .environmentObject(contactRepository)
            .toastBubble(toast: $awayTimeTracker.toast)
            .onChange(of: scenePhase) { _, newPhase in
                awayTimeTracker.handle(scenePhase: newPhase)
            }
        }
    }
}
