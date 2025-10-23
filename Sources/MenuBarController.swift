import Cocoa

class MenuBarController {
    private let statusItem: NSStatusItem
    private let captureController: CaptureController

    init(captureController: CaptureController) {
        self.captureController = captureController
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMenu()
        updateIcon()
    }

    private func setupMenu() {
        let menu = NSMenu()

        // Capture item
        let captureItem = NSMenuItem(
            title: "Capture (⌘⇧2)",
            action: #selector(captureAction),
            keyEquivalent: ""
        )
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func updateIcon() {
        if let button = statusItem.button {
            // Use SF Symbol for menu bar icon
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            let image = NSImage(systemSymbolName: "doc.text.viewfinder", accessibilityDescription: "SnipIt")
            image?.isTemplate = true
            button.image = image?.withSymbolConfiguration(config)
        }
    }

    @objc private func captureAction() {
        Task {
            await captureController.startCapture()
        }
    }
}
