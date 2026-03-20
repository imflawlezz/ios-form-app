//
//  KeyboardDismiss.swift
//  FormApp
//
//  Created by Yahor Artsiomchyk on 14/03/2026.
//

import SwiftUI
import UIKit

func dismissKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}

private struct KeyboardDismissOnTapOutside: UIViewRepresentable {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var window: UIWindow?
        var tapGestureRecognizer: UITapGestureRecognizer?

        func installIfNeeded() {
            guard tapGestureRecognizer == nil else { return }
            guard let keyWindow = Self.keyWindow else { return }

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tap.cancelsTouchesInView = false
            tap.delaysTouchesBegan = false
            tap.delegate = self

            keyWindow.addGestureRecognizer(tap)
            window = keyWindow
            tapGestureRecognizer = tap
        }

        func uninstall() {
            guard let tapGestureRecognizer else { return }
            window?.removeGestureRecognizer(tapGestureRecognizer)
            self.tapGestureRecognizer = nil
            window = nil
        }

        @objc private func handleTap() {
            dismissKeyboard()
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        private static var keyWindow: UIWindow? {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.installIfNeeded()
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.uninstall()
    }
}

extension View {

    func dismissKeyboardOnTap() -> some View {
        background(KeyboardDismissOnTapOutside().allowsHitTesting(false))
    }
}
