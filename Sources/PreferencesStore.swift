import Foundation
import Carbon

class PreferencesStore: ObservableObject {
    static let shared = PreferencesStore()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Key: String {
        case hasCompletedOnboarding
        case captureHotkeyKeyCode
        case captureHotkeyModifiers
        case preserveLineBreaks
        case appendToClipboard
        case ocrLanguages
        case recognitionLevel
        case showHUD
        case launchAtLogin
        case lastLicenseVerification
    }

    // MARK: - Onboarding
    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Key.hasCompletedOnboarding.rawValue) }
    }

    // MARK: - Hotkey
    @Published var captureHotkeyKeyCode: UInt32 {
        didSet { defaults.set(captureHotkeyKeyCode, forKey: Key.captureHotkeyKeyCode.rawValue) }
    }

    @Published var captureHotkeyModifiers: UInt32 {
        didSet { defaults.set(captureHotkeyModifiers, forKey: Key.captureHotkeyModifiers.rawValue) }
    }

    // MARK: - OCR Settings
    @Published var preserveLineBreaks: Bool {
        didSet { defaults.set(preserveLineBreaks, forKey: Key.preserveLineBreaks.rawValue) }
    }

    @Published var ocrLanguages: [String] {
        didSet { defaults.set(ocrLanguages, forKey: Key.ocrLanguages.rawValue) }
    }

    @Published var recognitionLevel: String {
        didSet { defaults.set(recognitionLevel, forKey: Key.recognitionLevel.rawValue) }
    }

    // MARK: - Clipboard
    @Published var appendToClipboard: Bool {
        didSet { defaults.set(appendToClipboard, forKey: Key.appendToClipboard.rawValue) }
    }

    // MARK: - UI
    @Published var showHUD: Bool {
        didSet { defaults.set(showHUD, forKey: Key.showHUD.rawValue) }
    }

    // MARK: - System
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Key.launchAtLogin.rawValue)
            updateLaunchAtLogin()
        }
    }

    // MARK: - License
    var lastLicenseVerification: Date? {
        get { defaults.object(forKey: Key.lastLicenseVerification.rawValue) as? Date }
        set { defaults.set(newValue, forKey: Key.lastLicenseVerification.rawValue) }
    }

    private init() {
        // Load or set defaults
        hasCompletedOnboarding = defaults.bool(forKey: Key.hasCompletedOnboarding.rawValue)

        // Default hotkey: Cmd+Shift+2
        let savedKeyCode = UInt32(defaults.integer(forKey: Key.captureHotkeyKeyCode.rawValue))
        captureHotkeyKeyCode = savedKeyCode == 0 ? UInt32(kVK_ANSI_2) : savedKeyCode

        let savedModifiers = UInt32(defaults.integer(forKey: Key.captureHotkeyModifiers.rawValue))
        captureHotkeyModifiers = savedModifiers == 0 ? UInt32(cmdKey | shiftKey) : savedModifiers

        preserveLineBreaks = defaults.object(forKey: Key.preserveLineBreaks.rawValue) as? Bool ?? true
        appendToClipboard = defaults.bool(forKey: Key.appendToClipboard.rawValue)
        ocrLanguages = defaults.stringArray(forKey: Key.ocrLanguages.rawValue) ?? ["en-US"]
        recognitionLevel = defaults.string(forKey: Key.recognitionLevel.rawValue) ?? "accurate"
        showHUD = defaults.object(forKey: Key.showHUD.rawValue) as? Bool ?? true
        launchAtLogin = defaults.bool(forKey: Key.launchAtLogin.rawValue)
    }

    private func updateLaunchAtLogin() {
        // Use SMLoginItemSetEnabled for macOS 13+
        if #available(macOS 13.0, *) {
            // Note: This requires a helper app or use of ServiceManagement framework
            // For now, we'll stub this out - implementation would use SMAppService
            // SMAppService.mainApp.register() / unregister()
        }
    }
}
