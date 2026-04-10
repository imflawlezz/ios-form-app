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

    @State private var lastBackgroundedAt: Date?
    @State private var awayMessage: String?

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContactListView()
            }
            .environmentObject(contactRepository)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background:
                    lastBackgroundedAt = Date()
                case .active:
                    guard let lastBackgroundedAt else { return }
                    let secondsAway = Int(Date().timeIntervalSince(lastBackgroundedAt).rounded(.down))
                    self.lastBackgroundedAt = nil

                    guard secondsAway > 0 else { return }
                    awayMessage = "Welcome back! You were away for \(Self.format(durationSeconds: secondsAway))."
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
            .alert("App resumed", isPresented: Binding(
                get: { awayMessage != nil },
                set: { if !$0 { awayMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    awayMessage = nil
                }
            } message: {
                Text(awayMessage ?? "")
            }
        }
    }

    private static func format(durationSeconds totalSeconds: Int) -> String {
        let seconds = max(0, totalSeconds)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(secs)s"
        }
        if minutes > 0 {
            return "\(minutes)m \(secs)s"
        }
        return "\(secs)s"
    }
}
