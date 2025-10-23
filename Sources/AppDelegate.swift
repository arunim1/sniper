import Cocoa
import ScreenCaptureKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var hotkeyService: HotkeyService?
    private var captureController: CaptureController?
    private var ocrService: OcrService?
    private var clipboardService: ClipboardService?
    private var licenseService: LicenseService?
    private var preferencesStore: PreferencesStore!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize services
        preferencesStore = PreferencesStore.shared
        licenseService = LicenseService(preferencesStore: preferencesStore)
        ocrService = OcrService(preferencesStore: preferencesStore)
        clipboardService = ClipboardService(preferencesStore: preferencesStore)
        captureController = CaptureController(
            ocrService: ocrService!,
            clipboardService: clipboardService!
        )

        // Set up menu bar
        menuBarController = MenuBarController(
            captureController: captureController!,
            licenseService: licenseService!,
            preferencesStore: preferencesStore
        )

        // Set up global hotkey
        hotkeyService = HotkeyService(preferencesStore: preferencesStore) { [weak self] in
            Task { @MainActor in
                await self?.handleCaptureHotkey()
            }
        }

        // Check for first run
        if !preferencesStore.hasCompletedOnboarding {
            showOnboarding()
        }

        // Check license status
        Task {
            await licenseService?.verifyLicenseIfNeeded()
        }
    }

    private func handleCaptureHotkey() async {
        // License check disabled for personal use
        // guard licenseService?.isLicenseValid ?? false else {
        //     await menuBarController?.showLicenseRequiredAlert()
        //     return
        // }

        // Check screen recording permission
        guard await checkScreenRecordingPermission() else {
            await menuBarController?.showScreenRecordingPermissionAlert()
            return
        }

        // Trigger capture
        await captureController?.startCapture()
    }

    private func checkScreenRecordingPermission() async -> Bool {
        if #available(macOS 14.0, *) {
            // Use ScreenCaptureKit permission check
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(
                    false,
                    onScreenWindowsOnly: true
                )
                return !content.displays.isEmpty
            } catch {
                return false
            }
        } else {
            // Fallback: attempt capture to test permission
            return true // Will fail later if no permission
        }
    }

    private func showOnboarding() {
        let onboardingController = OnboardingWindowController()
        onboardingController.showWindow(nil)
        onboardingController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
