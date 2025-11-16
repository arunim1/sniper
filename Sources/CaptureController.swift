import Cocoa
import ScreenCaptureKit

class CaptureController {
    private let ocrService: OcrService
    private let clipboardService: ClipboardService
    private var overlayWindow: SelectionOverlay?
    private var previousApp: NSRunningApplication?
    private var prewarmedOverlay: SelectionOverlay?

    init(ocrService: OcrService, clipboardService: ClipboardService) {
        self.ocrService = ocrService
        self.clipboardService = clipboardService
    }

    @MainActor
    func prewarmOverlay() {
        // Pre-create overlay window at launch for instant activation
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        prewarmedOverlay = SelectionOverlay(screen: screen)
    }

    @MainActor
    func startCapture() async {
        PerformanceTracker.recordTiming("MainActor dispatch complete")

        // Save the currently active application to restore later
        previousApp = NSWorkspace.shared.frontmostApplication

        // Get the screen where mouse cursor is currently located
        guard let currentScreen = NSScreen.main ?? NSScreen.screens.first else {
            showError("No screen available")
            restorePreviousApp()
            return
        }

        PerformanceTracker.recordTiming("Screen detection complete")

        // Use prewarmed overlay if available and matches screen, otherwise create new
        let overlay: SelectionOverlay
        if let prewarmed = prewarmedOverlay, prewarmed.overlayScreen.frame == currentScreen.frame {
            overlay = prewarmed
            prewarmedOverlay = nil
            PerformanceTracker.recordTiming("Using prewarmed overlay")
        } else {
            overlay = SelectionOverlay(screen: currentScreen)
            PerformanceTracker.recordTiming("Created new overlay")
        }

        self.overlayWindow = overlay

        return await withCheckedContinuation { continuation in
            overlay.show { [weak self] selectionRect in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                Task { @MainActor in
                    if let rect = selectionRect {
                        await self.captureAndProcessRegion(rect, on: currentScreen)
                    }
                    self.overlayWindow = nil
                    self.restorePreviousApp()

                    // Recreate prewarmed overlay for next activation
                    self.prewarmOverlay()

                    continuation.resume()
                }
            }
        }
    }

    @MainActor
    private func restorePreviousApp() {
        guard let app = previousApp else { return }

        // Activate the previous app to restore user's workflow
        app.activate(options: [.activateIgnoringOtherApps])

        // Clear the reference
        previousApp = nil
    }

    @MainActor
    private func captureAndProcessRegion(_ rect: CGRect, on screen: NSScreen) async {
        do {
            // Capture screenshot using ScreenCaptureKit
            let image = try await captureScreen(rect: rect, on: screen)

            // Perform OCR
            let recognizedText = try await ocrService.recognizeText(in: image)

            // Copy to clipboard - simple and fast, no popup
            clipboardService.copyToClipboard(recognizedText)

        } catch {
            // Silent fail - just don't crash
            print("Capture failed: \(error.localizedDescription)")
        }
    }

    private func captureScreen(rect: CGRect, on screen: NSScreen) async throws -> CGImage {
        // For now, use CGWindowListCreateImage which works on macOS 13+
        // ScreenCaptureKit's SCScreenshotManager.captureImage requires macOS 14+
        return try captureFallback(rect: rect)
    }

    // NOTE: ScreenCaptureKit methods commented out - SCScreenshotManager.captureImage requires macOS 14+
    // Keeping CGWindowListCreateImage for now which works on macOS 13+

    private func captureFallback(rect: CGRect) throws -> CGImage {
        // Fallback for older macOS versions using CGWindowListCreateImage
        // Note: This is deprecated in macOS 15+ but needed for 10.15-12.x support
        let cgRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y,
            width: rect.width,
            height: rect.height
        )

        guard let image = CGWindowListCreateImage(
            cgRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        ) else {
            throw CaptureError.captureFailed
        }

        return image
    }

    @MainActor
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Capture Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

enum CaptureError: LocalizedError {
    case noDisplayFound
    case captureFailed
    case ocrFailed

    var errorDescription: String? {
        switch self {
        case .noDisplayFound:
            return "Could not find display for capture"
        case .captureFailed:
            return "Failed to capture screen region"
        case .ocrFailed:
            return "Failed to recognize text"
        }
    }
}
