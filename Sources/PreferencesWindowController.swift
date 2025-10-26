import Cocoa
import SwiftUI
import Carbon

class PreferencesWindowController: NSWindowController {
    convenience init(preferencesStore: PreferencesStore) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.center()

        let hostingView = NSHostingView(rootView: PreferencesView(preferencesStore: preferencesStore))
        window.contentView = hostingView

        self.init(window: window)
    }
}

struct PreferencesView: View {
    @ObservedObject var preferencesStore: PreferencesStore
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            Picker("", selection: $selectedTab) {
                Text("General").tag(0)
                Text("Shortcut").tag(1)
                Text("OCR").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Content
            ScrollView {
                switch selectedTab {
                case 0:
                    GeneralPreferencesView(preferencesStore: preferencesStore)
                case 1:
                    ShortcutPreferencesView(preferencesStore: preferencesStore)
                case 2:
                    OCRPreferencesView(preferencesStore: preferencesStore)
                default:
                    EmptyView()
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct GeneralPreferencesView: View {
    @ObservedObject var preferencesStore: PreferencesStore

    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $preferencesStore.launchAtLogin)
                Toggle("Show HUD Notification", isOn: $preferencesStore.showHUD)
                Toggle("Append to Clipboard", isOn: $preferencesStore.appendToClipboard)
            } header: {
                Text("General")
                    .font(.headline)
            }
            .padding()
        }
        .formStyle(.grouped)
    }
}

struct ShortcutPreferencesView: View {
    @ObservedObject var preferencesStore: PreferencesStore

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Capture Shortcut:")
                    Spacer()
                    Text(formatHotkey())
                        .padding(6)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }

                Text("Default: ⌘⇧2")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("To change the shortcut, a custom shortcut recorder would be implemented here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Keyboard Shortcuts")
                    .font(.headline)
            }
            .padding()
        }
        .formStyle(.grouped)
    }

    private func formatHotkey() -> String {
        var result = ""
        let modifiers = preferencesStore.captureHotkeyModifiers

        if modifiers & UInt32(cmdKey) != 0 {
            result += "⌘"
        }
        if modifiers & UInt32(shiftKey) != 0 {
            result += "⇧"
        }
        if modifiers & UInt32(optionKey) != 0 {
            result += "⌥"
        }
        if modifiers & UInt32(controlKey) != 0 {
            result += "⌃"
        }

        // Map key code to character (simplified)
        let keyCode = preferencesStore.captureHotkeyKeyCode
        if keyCode == UInt32(kVK_ANSI_2) {
            result += "2"
        } else {
            result += "\(keyCode)"
        }

        return result
    }
}

struct OCRPreferencesView: View {
    @ObservedObject var preferencesStore: PreferencesStore

    var body: some View {
        Form {
            Section {
                Toggle("Preserve Line Breaks", isOn: $preferencesStore.preserveLineBreaks)

                Picker("Recognition Speed", selection: $preferencesStore.recognitionLevel) {
                    Text("Fast").tag("fast")
                    Text("Accurate").tag("accurate")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Languages")
                        .font(.subheadline)

                    Text("Supported: \(preferencesStore.ocrLanguages.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("A full language selector would be implemented here.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("OCR Settings")
                    .font(.headline)
            }
            .padding()
        }
        .formStyle(.grouped)
    }
}

