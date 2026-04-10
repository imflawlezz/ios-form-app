//
//  ContactPersistence.swift
//  FormApp
//

import Foundation
import os

private let persistenceLog = Logger(subsystem: "FormApp", category: "ContactPersistence")

class ContactPersistence {
    private static let fileName = "contacts.json"
    private static let subdirectory = "FormApp"

    private static var storageDirectoryURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(subdirectory, isDirectory: true)
    }

    private static var fileURL: URL {
        storageDirectoryURL.appendingPathComponent(fileName, isDirectory: false)
    }

    static func load() -> [Contact] {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            persistenceLog.debug("No contacts file yet at \(url.path, privacy: .public)")
            return []
        }
        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let contacts = try decoder.decode([Contact].self, from: data)
            persistenceLog.info("Loaded \(contacts.count, privacy: .public) contacts")
            return contacts
        } catch {
            persistenceLog.error("Failed to decode contacts: \(error.localizedDescription, privacy: .public)")
            quarantineCorruptFile(at: url)
            return []
        }
    }

    static func save(_ contacts: [Contact]) {
        do {
            try ensureStorageDirectoryExists()
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            let data = try encoder.encode(contacts)

            let url = fileURL
            let backupURL = url.appendingPathExtension("bak")
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: backupURL)
                try? FileManager.default.copyItem(at: url, to: backupURL)
            }

            try data.write(to: url, options: [.atomic])
            persistenceLog.debug("Saved \(contacts.count, privacy: .public) contacts")
        } catch {
            persistenceLog.error("Failed to save contacts: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func ensureStorageDirectoryExists() throws {
        let dir = storageDirectoryURL
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private static func quarantineCorruptFile(at url: URL) {
        let stamp = Int(Date().timeIntervalSince1970)
        let dest = url.deletingLastPathComponent().appendingPathComponent("contacts.json.corrupt.\(stamp)")
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.moveItem(at: url, to: dest)
            persistenceLog.notice("Moved corrupt contacts file to \(dest.lastPathComponent, privacy: .public)")
        } catch {
            persistenceLog.error("Could not quarantine corrupt file: \(error.localizedDescription, privacy: .public)")
            try? FileManager.default.removeItem(at: url)
        }
    }
}
