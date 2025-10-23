import Cocoa
import SwiftUI
import ScreenCaptureKit

class OnboardingWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Welcome to SnipIt"
        window.center()

        let hostingView = NSHostingView(rootView: OnboardingView())
        window.contentView = hostingView

        self.init(window: window)
    }
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var hasScreenRecordingPermission = false
    @State private var isCheckingPermission = false

    let pages = [
        OnboardingPage(
            icon: "doc.text.viewfinder",
            title: "Welcome to SnipIt",
            description: "Capture and OCR any text on your screen instantly with a simple keyboard shortcut.",
            primaryAction: "Next"
        ),
        OnboardingPage(
            icon: "keyboard",
            title: "Quick Capture",
            description: "Press ⌘⇧2 (Command + Shift + 2) anytime to start capturing. Select the region you want to OCR.",
            primaryAction: "Next"
        ),
        OnboardingPage(
            icon: "lock.shield",
            title: "Privacy First",
            description: "All OCR processing happens locally on your device. No data is sent to external servers.",
            primaryAction: "Next"
        ),
        OnboardingPage(
            icon: "checklist",
            title: "Permission Required",
            description: "SnipIt needs Screen Recording permission to capture regions of your screen for OCR.",
            primaryAction: "Grant Permission"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    pageView(for: pages[index], at: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
            .frame(height: 400)

            // Navigation
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }

                Spacer()

                if currentPage == pages.count - 1 {
                    Button(hasScreenRecordingPermission ? "Get Started" : "Grant Permission") {
                        if hasScreenRecordingPermission {
                            completeOnboarding()
                        } else {
                            requestPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCheckingPermission)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .onAppear {
            checkPermission()
        }
    }

    private func pageView(for page: OnboardingPage, at index: Int) -> some View {
        VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 72))
                .foregroundColor(.accentColor)

            Text(page.title)
                .font(.title)
                .bold()

            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if index == pages.count - 1 {
                // Permission status
                HStack {
                    Image(systemName: hasScreenRecordingPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(hasScreenRecordingPermission ? .green : .red)

                    Text(hasScreenRecordingPermission ? "Permission Granted" : "Permission Required")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

                if !hasScreenRecordingPermission {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps:")
                            .font(.caption)
                            .bold()

                        Text("1. Click 'Grant Permission' below")
                            .font(.caption)
                        Text("2. Open System Settings > Privacy & Security > Screen Recording")
                            .font(.caption)
                        Text("3. Enable SnipIt in the list")
                            .font(.caption)
                        Text("4. Return here and click 'Test Capture'")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

                    Button("Test Capture") {
                        testCapture()
                    }
                    .disabled(isCheckingPermission)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func checkPermission() {
        isCheckingPermission = true

        Task {
            let hasPermission = await checkScreenRecordingPermission()

            await MainActor.run {
                hasScreenRecordingPermission = hasPermission
                isCheckingPermission = false
            }
        }
    }

    private func requestPermission() {
        // Open System Settings
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security")!)
        }
    }

    private func testCapture() {
        checkPermission()
    }

    private func completeOnboarding() {
        PreferencesStore.shared.hasCompletedOnboarding = true

        // Close window
        if let window = NSApp.windows.first(where: { $0.title == "Welcome to SnipIt" }) {
            window.close()
        }
    }

    private func checkScreenRecordingPermission() async -> Bool {
        if #available(macOS 14.0, *) {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(
                    false,
                    onScreenWindowsOnly: true
                )
                return !content.displays.isEmpty
            } catch {
                return false
            }
        } else if #available(macOS 13.0, *) {
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
            // For older versions, assume permission is granted if we get here
            return true
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let primaryAction: String
}
