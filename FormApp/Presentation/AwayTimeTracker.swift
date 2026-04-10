import Combine
import SwiftUI

struct ToastData: Identifiable, Equatable {
    let id: UUID
    let message: String

    init(id: UUID = UUID(), message: String) {
        self.id = id
        self.message = message
    }
}

@MainActor
final class AwayTimeTracker: ObservableObject {
    @Published var toast: ToastData?

    private var lastBackgroundedAt: Date?

    func handle(scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            lastBackgroundedAt = Date()
        case .active:
            guard let lastBackgroundedAt else { return }
            self.lastBackgroundedAt = nil

            let secondsAway = Int(Date().timeIntervalSince(lastBackgroundedAt).rounded(.down))
            guard secondsAway > 0 else { return }

            toast = ToastData(message: "Time away: \(Self.format(durationSeconds: secondsAway))")
        case .inactive:
            break
        @unknown default:
            break
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
