import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var hotkeyService: HotkeyService?
    private var captureController: CaptureController?
    private var ocrService: OcrService?
    private var clipboardService: ClipboardService?

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
            Task { @MainActor in
                await self?.captureController?.startCapture()
            }
        }

        // Prewarm overlay window for instant activation
        Task { @MainActor in
            self.captureController?.prewarmOverlay()
        }
    }
}
