import Cocoa

class SelectionOverlay: NSWindow {
    private let overlayView: SelectionOverlayView
    private var completion: ((CGRect?) -> Void)?

    init(screen: NSScreen) {
        let frame = screen.frame
        overlayView = SelectionOverlayView(frame: frame)

        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.contentView = overlayView
        self.level = .screenSaver
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        overlayView.selectionCallback = { [weak self] rect in
            self?.finishSelection(with: rect)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(completion: @escaping (CGRect?) -> Void) {
        self.completion = completion
        makeKeyAndOrderFront(nil)
        NSCursor.crosshair.set()
    }

    private func finishSelection(with rect: CGRect?) {
        NSCursor.arrow.set()
        orderOut(nil)
        completion?(rect)
    }
}

class SelectionOverlayView: NSView {
    var selectionCallback: ((CGRect?) -> Void)?

    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var isDragging = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTrackingArea()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTrackingArea() {
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseMoved, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        isDragging = true
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isDragging, let start = startPoint, let end = currentPoint else {
            selectionCallback?(nil)
            return
        }

        isDragging = false

        // Calculate selection rectangle
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)

        // Only return if selection has meaningful size
        if width > 10 && height > 10 {
            // Convert to screen coordinates
            guard let window = window else {
                selectionCallback?(nil)
                return
            }

            let windowRect = CGRect(x: minX, y: minY, width: width, height: height)
            let screenRect = window.convertToScreen(windowRect)

            // Flip Y coordinate (macOS screen coordinates start from bottom-left)
            let flippedY = NSScreen.screens[0].frame.height - screenRect.maxY
            let finalRect = CGRect(x: screenRect.minX, y: flippedY, width: width, height: height)

            selectionCallback?(finalRect)
        } else {
            selectionCallback?(nil)
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            selectionCallback?(nil)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Draw semi-transparent overlay
        NSColor.black.withAlphaComponent(0.3).setFill()
        bounds.fill()

        guard isDragging, let start = startPoint, let end = currentPoint else { return }

        // Calculate selection rectangle
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)
        let selectionRect = CGRect(x: minX, y: minY, width: width, height: height)

        // Clear selection area (make it transparent)
        NSColor.clear.setFill()
        selectionRect.fill(using: .copy)

        // Draw border
        NSColor.systemBlue.setStroke()
        let path = NSBezierPath(rect: selectionRect)
        path.lineWidth = 2
        path.stroke()

        // Draw size label
        if width > 50 && height > 30 {
            let sizeText = String(format: "%.0f × %.0f", width, height)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: NSColor.white,
                .backgroundColor: NSColor.black.withAlphaComponent(0.7)
            ]

            let attributedString = NSAttributedString(string: " \(sizeText) ", attributes: attributes)
            let textSize = attributedString.size()

            let textPoint = CGPoint(
                x: selectionRect.midX - textSize.width / 2,
                y: selectionRect.minY - textSize.height - 4
            )

            attributedString.draw(at: textPoint)
        }
    }
}
