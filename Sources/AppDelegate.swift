import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var hotkeyService: HotkeyService?
    private var captureController: CaptureController?
    private var ocrService: OcrService?
    private var clipboardService: ClipboardService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let startTime = Date().timeIntervalSince1970
        logPerf("App launch started")

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

        let endTime = Date().timeIntervalSince1970
        let elapsed = (endTime - startTime) * 1000
        logPerf("App ready in \(String(format: "%.2f", elapsed))ms")
    }

    private func logPerf(_ message: String) {
        let timestamp = Date().timeIntervalSince1970
        let logMessage = "[\(timestamp)] \(message)\n"
        let logPath = "/tmp/sniper_perf.log"
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logPath) {
                if let fileHandle = FileHandle(forWritingAtPath: logPath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: URL(fileURLWithPath: logPath))
            }
        }
    }
}
