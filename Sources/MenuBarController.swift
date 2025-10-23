import Cocoa

class MenuBarController {
    private let statusItem: NSStatusItem
    private let captureController: CaptureController
    private let licenseService: LicenseService
    private let preferencesStore: PreferencesStore
    private var preferencesWindowController: PreferencesWindowController?

    init(
        captureController: CaptureController,
        licenseService: LicenseService,
        preferencesStore: PreferencesStore
    ) {
        self.captureController = captureController
        self.licenseService = licenseService
        self.preferencesStore = preferencesStore

        // Create status item
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

        // Preferences
        let preferencesItem = NSMenuItem(
            title: "Preferences…",
            action: #selector(showPreferences),
            keyEquivalent: ","
        )
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        // License
        let licenseItem = NSMenuItem(
            title: licenseService.isLicenseValid ? "Manage License…" : "Enter License…",
            action: #selector(showLicense),
            keyEquivalent: ""
        )
        licenseItem.target = self
        menu.addItem(licenseItem)

        menu.addItem(NSMenuItem.separator())

        // About
        let aboutItem = NSMenuItem(
            title: "About SnipIt",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit SnipIt",
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

    @objc private func showPreferences() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController(preferencesStore: preferencesStore)
        }
        preferencesWindowController?.showWindow(nil)
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showLicense() {
        let licenseWindowController = LicenseWindowController(licenseService: licenseService)
        licenseWindowController.showWindow(nil)
        licenseWindowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @MainActor
    func showLicenseRequiredAlert() {
        let alert = NSAlert()
        alert.messageText = "License Required"
        alert.informativeText = "Please enter a valid license key to use SnipIt."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Enter License")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            showLicense()
        }
    }

    @MainActor
    func showScreenRecordingPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "SnipIt needs permission to record your screen to capture regions for OCR. Please grant permission in System Settings."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openScreenRecordingSettings()
        }
    }

    private func openScreenRecordingSettings() {
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security")!)
        }
    }
}
