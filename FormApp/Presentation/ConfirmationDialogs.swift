import SwiftUI

extension View {
    func confirmDeleteContact(isPresented: Binding<Bool>, contactName: String, onDelete: @escaping () -> Void) -> some View {
        confirmationDialog("Delete contact?", isPresented: isPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Remove \(contactName) from your contacts? This cannot be undone.")
        }
    }

    func confirmDeleteAllContacts(isPresented: Binding<Bool>, onDelete: @escaping () -> Void) -> some View {
        confirmationDialog("Delete all contacts?", isPresented: isPresented, titleVisibility: .visible) {
            Button("Delete all", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }
}

