import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var hotkeyService: HotkeyService?
    private var captureController: CaptureController?
    private var ocrService: OcrService?
    private var clipboardService: ClipboardService?
    private var previousActiveApp: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize minimal services
        ocrService = OcrService()
        clipboardService = ClipboardService()
        captureController = CaptureController(
            ocrService: ocrService!,
            clipboardService: clipboardService!
        )

        // Set up menu bar
        menuBarController = MenuBarController(captureController: captureController!)

        // Set up global hotkey (⌘⇧2) - just capture, no checks
        hotkeyService = HotkeyService { [weak self] in
            // Capture the currently active app before we take over
            self?.previousActiveApp = NSWorkspace.shared.frontmostApplication

            Task { @MainActor in
                await self?.captureController?.startCapture()
                // Restore the previous app after capture completes (success, failure, or abort)
                self?.restorePreviousApp()
            }
        }
    }

    private func restorePreviousApp() {
        // Restore focus to the app that was active when the hotkey was pressed
        guard let app = previousActiveApp, app.isRunning else {
            return
        }

        app.activate(options: .activateAllWindows)
        previousActiveApp = nil
    }
}
