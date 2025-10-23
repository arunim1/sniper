import Cocoa

@MainActor
class HUDController {
    static let shared = HUDController()

    private var hudWindow: NSPanel?
    private var hideTask: Task<Void, Never>?

    private init() {}

    func show(message: String, duration: TimeInterval = 2.0) {
        // Cancel any existing hide task
        hideTask?.cancel()

        // Create or update HUD
        if hudWindow == nil {
            createHUD()
        }

        updateHUD(with: message)

        // Show HUD
        hudWindow?.orderFrontRegardless()
        hudWindow?.alphaValue = 1.0

        // Schedule hide
        hideTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

            if !Task.isCancelled {
                await hideHUD()
            }
        }
    }

    private func createHUD() {
        let hudSize = CGSize(width: 200, height: 80)

        // Center on screen
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame
        let origin = CGPoint(
            x: screenRect.midX - hudSize.width / 2,
            y: screenRect.midY - hudSize.height / 2
        )
        let rect = CGRect(origin: origin, size: hudSize)

        // Create window
        let panel = NSPanel(
            contentRect: rect,
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Create visual effect view
        let visualEffectView = NSVisualEffectView(frame: panel.contentView!.bounds)
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 12

        // Create stack view for content
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Create icon
        let iconImageView = NSImageView()
        iconImageView.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Success")
        iconImageView.contentTintColor = .systemGreen
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        // Create label
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .labelColor
        label.alignment = .center
        label.maximumNumberOfLines = 2
        label.identifier = NSUserInterfaceItemIdentifier("messageLabel")

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)

        visualEffectView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: visualEffectView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: visualEffectView.trailingAnchor, constant: -16)
        ])

        panel.contentView = visualEffectView
        hudWindow = panel
    }

    private func updateHUD(with message: String) {
        guard let contentView = hudWindow?.contentView as? NSVisualEffectView else { return }

        // Find label
        if let stackView = contentView.subviews.first(where: { $0 is NSStackView }) as? NSStackView,
           let label = stackView.arrangedSubviews.first(where: {
               $0.identifier?.rawValue == "messageLabel"
           }) as? NSTextField {
            label.stringValue = message
        }
    }

    private func hideHUD() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            hudWindow?.animator().alphaValue = 0.0
        } completionHandler: { [weak self] in
            self?.hudWindow?.orderOut(nil)
        }
    }
}
