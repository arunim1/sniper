import Cocoa

class ClipboardService {
    private let preferencesStore: PreferencesStore
    private let pasteboard = NSPasteboard.general

    init(preferencesStore: PreferencesStore) {
        self.preferencesStore = preferencesStore
    }

    func copyToClipboard(_ text: String) {
        if preferencesStore.appendToClipboard {
            appendToClipboard(text)
        } else {
            replaceClipboard(text)
        }
    }

    private func replaceClipboard(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func appendToClipboard(_ text: String) {
        let existingText = pasteboard.string(forType: .string) ?? ""
        let newText = existingText.isEmpty ? text : "\(existingText)\n\n\(text)"
        pasteboard.clearContents()
        pasteboard.setString(newText, forType: .string)
    }

    func getClipboardText() -> String? {
        return pasteboard.string(forType: .string)
    }
}
