import SwiftUI

struct ContactActionRow: View {
    let canCall: Bool
    let onCall: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            actionButton(
                title: "Call",
                systemImage: "phone.fill",
                tint: .green,
                isEnabled: canCall,
                action: onCall
            )

            actionButton(
                title: "Edit",
                systemImage: "pencil",
                tint: .indigo,
                isEnabled: true,
                action: onEdit
            )

            actionButton(
                title: "Delete",
                systemImage: "trash",
                tint: .red,
                isEnabled: true,
                action: onDelete
            )
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func actionButton(
        title: String,
        systemImage: String,
        tint: Color,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .tint(tint)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .accessibilityLabel(title)
    }
}

