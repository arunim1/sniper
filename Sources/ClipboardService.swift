import Cocoa

class ClipboardService {
    private let pasteboard = NSPasteboard.general

    init() {}

    func copyToClipboard(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
