import Cocoa
import ScreenCaptureKit

class CaptureController {
    private let ocrService: OcrService
    private let clipboardService: ClipboardService
    private var overlayWindow: SelectionOverlay?

    init(ocrService: OcrService, clipboardService: ClipboardService) {
        self.ocrService = ocrService
        self.clipboardService = clipboardService
    }

    @MainActor
    func startCapture() async {
        // Get the screen where mouse cursor is currently located
        guard let currentScreen = NSScreen.main ?? NSScreen.screens.first else {
            showError("No screen available")
            return
        }

        // Show selection overlay
        let overlay = SelectionOverlay(screen: currentScreen)
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
                    continuation.resume()
                }
            }
        }
    }

    @MainActor
    private func captureAndProcessRegion(_ rect: CGRect, on screen: NSScreen) async {
        do {
            // Capture screenshot using ScreenCaptureKit
            let image = try await captureScreen(rect: rect, on: screen)

            // Perform OCR
            let recognizedText = try await ocrService.recognizeText(in: image)

            // Copy to clipboard
            clipboardService.copyToClipboard(recognizedText)

            // Show HUD
            if PreferencesStore.shared.showHUD {
                HUDController.shared.show(
                    message: "Copied \(recognizedText.count) characters",
                    duration: 2.0
                )
            }

        } catch {
            showError("Failed to capture: \(error.localizedDescription)")
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
