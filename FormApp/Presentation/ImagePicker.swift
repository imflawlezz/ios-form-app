import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    var cameraDevice: UIImagePickerController.CameraDevice = .rear
    var allowsEditing: Bool = false

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = cameraDevice
        picker.allowsEditing = allowsEditing
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .fullScreen
        picker.modalPresentationCapturesStatusBarAppearance = true
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = parent.allowsEditing
                ? (info[.editedImage] as? UIImage)
                : (info[.originalImage] as? UIImage)

            if let image, let data = image.jpegData(compressionQuality: 0.85) {
                parent.onCapture(data)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
