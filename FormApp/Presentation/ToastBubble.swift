import SwiftUI

struct ToastBubble: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "timer")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
        .accessibilityAddTraits(.isStaticText)
    }
}

private struct ToastBubbleModifier: ViewModifier {
    @Binding var toast: ToastData?
    let autoDismissAfter: Duration

    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast {
                    ToastBubble(message: toast.message)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture { dismiss(animated: true) }
                        .onAppear {
                            scheduleDismiss()
                        }
                        .onChange(of: toast.id) { _, _ in
                            scheduleDismiss()
                        }
                        .accessibilityLabel(toast.message)
                        .accessibilityHint("Double tap to dismiss.")
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.86), value: toast?.id)
    }

    private func scheduleDismiss() {
        dismissTask?.cancel()
        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: autoDismissAfter)
            dismiss(animated: true)
        }
    }

    private func dismiss(animated: Bool) {
        dismissTask?.cancel()
        dismissTask = nil

        if animated {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                toast = nil
            }
        } else {
            toast = nil
        }
    }
}

extension View {
    func toastBubble(toast: Binding<ToastData?>, autoDismissAfter: Duration = .seconds(3)) -> some View {
        modifier(ToastBubbleModifier(toast: toast, autoDismissAfter: autoDismissAfter))
    }
}
