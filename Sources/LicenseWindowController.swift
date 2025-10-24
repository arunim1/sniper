import Cocoa
import SwiftUI

class LicenseWindowController: NSWindowController {
    private let licenseService: LicenseService

    init(licenseService: LicenseService) {
        self.licenseService = licenseService

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "License"
        window.center()

        super.init(window: window)

        let hostingView = NSHostingView(
            rootView: LicenseView(
                licenseService: licenseService,
                onClose: { [weak self] in
                    self?.close()
                }
            )
        )
        window.contentView = hostingView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LicenseView: View {
    let licenseService: LicenseService
    let onClose: () -> Void

    @State private var licenseKey = ""
    @State private var isVerifying = false
    @State private var verificationMessage = ""
    @State private var verificationSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            if licenseService.isLicenseValid {
                // Already licensed
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)

                    Text("Sniper is Licensed")
                        .font(.title2)
                        .bold()

                    Text("Thank you for your purchase!")
                        .foregroundColor(.secondary)

                    Button("Deactivate License") {
                        deactivateLicense()
                    }
                    .foregroundColor(.red)
                }
                .padding()
            } else {
                // License entry form
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)

                    Text("Enter License Key")
                        .font(.title2)
                        .bold()

                    Text("Enter the license key from your Gumroad purchase email.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    TextField("License Key", text: $licenseKey)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 300)
                        .disabled(isVerifying)

                    if !verificationMessage.isEmpty {
                        Text(verificationMessage)
                            .font(.caption)
                            .foregroundColor(verificationSuccess ? .green : .red)
                            .multilineTextAlignment(.center)
                    }

                    HStack {
                        Button("Cancel") {
                            onClose()
                        }
                        .disabled(isVerifying)

                        Button("Activate") {
                            activateLicense()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(licenseKey.isEmpty || isVerifying)
                    }

                    if isVerifying {
                        ProgressView()
                            .scaleEffect(0.7)
                    }

                    Spacer()

                    Button("Purchase License") {
                        purchaseLicense()
                    }
                    .font(.caption)
                }
                .padding()
            }
        }
        .frame(width: 400, height: 300)
    }

    private func activateLicense() {
        isVerifying = true
        verificationMessage = ""

        Task {
            let result = await licenseService.verifyLicense(
                licenseKey: licenseKey,
                incrementUses: true
            )

            await MainActor.run {
                isVerifying = false
                verificationSuccess = result.success
                verificationMessage = result.message

                if result.success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onClose()
                    }
                }
            }
        }
    }

    private func deactivateLicense() {
        licenseService.deactivateLicense()
        onClose()
    }

    private func purchaseLicense() {
        // Open Gumroad purchase page
        if let url = URL(string: "https://gumroad.com/l/sniper") {
            NSWorkspace.shared.open(url)
        }
    }
}
