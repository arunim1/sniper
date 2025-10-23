import Foundation
import Carbon

class HotkeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let preferencesStore: PreferencesStore
    private let callback: () -> Void

    private static var instance: HotkeyService?
    private static let hotkeyID = EventHotKeyID(signature: OSType(0x53_4e_49_50), id: 1) // 'SNIP'

    init(preferencesStore: PreferencesStore, callback: @escaping () -> Void) {
        self.preferencesStore = preferencesStore
        self.callback = callback
        Self.instance = self
        registerHotkey()
    }

    deinit {
        unregisterHotkey()
        Self.instance = nil
    }

    func registerHotkey() {
        unregisterHotkey()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                HotkeyService.instance?.handleHotkeyEvent()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )

        guard status == noErr else {
            print("Failed to install event handler: \(status)")
            return
        }

        let registerStatus = RegisterEventHotKey(
            preferencesStore.captureHotkeyKeyCode,
            preferencesStore.captureHotkeyModifiers,
            Self.hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerStatus != noErr {
            print("Failed to register hotkey: \(registerStatus)")
            // Attempt fallback or notify user
        }
    }

    func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    private func handleHotkeyEvent() {
        callback()
    }

    func updateHotkey(keyCode: UInt32, modifiers: UInt32) {
        preferencesStore.captureHotkeyKeyCode = keyCode
        preferencesStore.captureHotkeyModifiers = modifiers
        registerHotkey()
    }
}
