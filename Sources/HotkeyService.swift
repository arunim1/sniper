import Foundation
import Carbon

class HotkeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let callback: () -> Void

    private static var instance: HotkeyService?
    private static let hotkeyID = EventHotKeyID(signature: OSType(0x53_4e_49_50), id: 1) // 'SNIP'

    init(callback: @escaping () -> Void) {
        self.callback = callback
        Self.instance = self
        registerHotkey()
    }

    deinit {
        unregisterHotkey()
        Self.instance = nil
    }

    private func registerHotkey() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                HotkeyService.instance?.callback()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )

        // Register ⌘⇧2
        RegisterEventHotKey(
            UInt32(kVK_ANSI_2),           // Key code for '2'
            UInt32(cmdKey | shiftKey),     // ⌘⇧
            Self.hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
}
