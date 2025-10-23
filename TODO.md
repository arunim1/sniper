# SnipIt TODO List

## Immediate (Pre-V1 Release)

### Critical
- [ ] **Test build in Xcode** - Verify project compiles and runs
- [ ] **Configure Gumroad Product ID** - Replace placeholder in LicenseService.swift
- [ ] **Set up code signing** - Add Developer ID certificate
- [ ] **Test on clean macOS installation** - Verify onboarding and permissions
- [ ] **Generate Sparkle keys** - Create EdDSA keypair for updates
- [ ] **Create app icon** - Design and add .icns file to Resources/

### High Priority
- [ ] **Test multi-display scenarios** - Verify capture works across monitors
- [ ] **Test various scaling factors** - 1×, 2×, 3× (Retina)
- [ ] **Test OCR with different content types**:
  - [ ] Clear printed text
  - [ ] Small UI text
  - [ ] Code snippets
  - [ ] Non-English languages
  - [ ] Low contrast text
- [ ] **Performance profiling** - Use Instruments to verify < 500ms P95
- [ ] **Memory leak check** - Run with Instruments leak detector
- [ ] **Edge cases**:
  - [ ] Very large selection (> 4K resolution)
  - [ ] Very small selection (< 20×20 pixels)
  - [ ] Empty selection
  - [ ] Rapid repeated captures

### Medium Priority
- [ ] **Error handling improvements**:
  - [ ] Network timeout for license verification
  - [ ] OCR failures with helpful messages
  - [ ] Permission denied scenarios
- [ ] **UX polish**:
  - [ ] Better error dialogs with recovery actions
  - [ ] Loading states during OCR
  - [ ] Settings validation (e.g., hotkey conflicts)
- [ ] **Accessibility**:
  - [ ] VoiceOver labels for all controls
  - [ ] Keyboard navigation in preferences
  - [ ] High contrast mode support
- [ ] **Localization** (optional for V1):
  - [ ] Extract strings to .strings files
  - [ ] Translate UI to major languages

### Documentation
- [ ] **Create CHANGELOG.md** - Version history
- [ ] **Write CONTRIBUTING.md** - If open-sourcing
- [ ] **Privacy Policy** - Document data handling
- [ ] **License Agreement** - EULA for app
- [ ] **Support Documentation** - FAQ and troubleshooting
- [ ] **Video tutorial** - How to use SnipIt

### Distribution
- [ ] **Create DMG template** - Branded disk image
- [ ] **Set up update feed** - Host appcast.xml
- [ ] **Create landing page** - Marketing website
- [ ] **Set up Gumroad product** - Pricing and checkout
- [ ] **Beta testing** - TestFlight or direct distribution
- [ ] **App Store submission** (optional) - Different license validation

## V1.x Enhancements

### Features
- [ ] **Full hotkey recorder UI** - Visual shortcut picker
- [ ] **Launch at login implementation** - SMAppService integration
- [ ] **Capture from menu bar** - Quick capture without hotkey
- [ ] **Recent captures menu** - Quick access to last 5 captures
- [ ] **Copy as markdown** - Format code blocks, URLs
- [ ] **Copy as formatted text** - Preserve styling hints
- [ ] **Confidence threshold setting** - Warn on low-quality OCR
- [ ] **Manual language override** - Per-capture language selection
- [ ] **Post-OCR editing** - Edit before copying
- [ ] **Sound effects** - Optional audio feedback
- [ ] **Multiple hotkeys** - Different actions (copy, append, etc.)

### Improvements
- [ ] **Better text grouping** - Smarter column detection
- [ ] **Orientation detection** - Handle rotated text
- [ ] **Math equation support** - Special handling for formulas
- [ ] **Code detection** - Better monospace preservation
- [ ] **URL extraction** - Separate URLs from text
- [ ] **Email extraction** - Detect and format emails
- [ ] **Phone number extraction** - Recognize phone formats
- [ ] **Date/time parsing** - Extract and normalize dates

### Technical Debt
- [ ] **Unit tests** - Cover core logic (OcrService, LicenseService)
- [ ] **UI tests** - Automated testing of user flows
- [ ] **CI/CD pipeline** - GitHub Actions for building
- [ ] **Crash reporting** - Optional analytics/crashlytics
- [ ] **Logging framework** - Structured logging with levels
- [ ] **Performance monitoring** - Track OCR latency distribution
- [ ] **A/B testing framework** - For feature rollouts

## V2.0 Major Features

### Planned (From Requirements)
- [ ] **QR Code Reader** - VNDetectBarcodesRequest
- [ ] **Barcode Scanner** - Support various barcode formats
- [ ] **Text-to-Speech** - AVSpeechSynthesizer integration
- [ ] **Capture History** - CoreData persistence
- [ ] **History Browser** - Search and re-copy old captures
- [ ] **Table Detection** - VNDetectDocumentSegmentationRequest
- [ ] **CSV Export** - Convert tables to structured data
- [ ] **CLI Interface** - ArgumentParser command-line tool
- [ ] **AppleScript Support** - Scriptable actions
- [ ] **URL Scheme** - `snipit://capture` deep linking
- [ ] **Drag & Drop OCR** - Drop image files to OCR
- [ ] **Redaction Mode** - Auto-detect and blur sensitive info

### New Ideas
- [ ] **Cloud Sync** - iCloud sync for history (optional)
- [ ] **Shared Captures** - Generate shareable links
- [ ] **Team Features** - Shared capture libraries
- [ ] **OCR API** - Expose as service for other apps
- [ ] **Browser Extension** - OCR for web images
- [ ] **iOS Companion** - Universal clipboard integration
- [ ] **Watch App** - Quick capture trigger
- [ ] **Shortcuts Integration** - macOS Shortcuts actions
- [ ] **Focus Mode Integration** - Respect Do Not Disturb

### Advanced OCR
- [ ] **Multi-language auto-detect** - No manual selection needed
- [ ] **Mixed-language support** - Handle multilingual text
- [ ] **Document structure** - Detect headers, paragraphs, lists
- [ ] **Form field extraction** - Label-value pairs
- [ ] **Handwriting recognition** - Vision handwriting support
- [ ] **Receipt parsing** - Extract line items and totals
- [ ] **Business card parsing** - Extract contact info
- [ ] **PDF generation** - Save captures as searchable PDFs

## Technical Improvements

### Architecture
- [ ] **Modular architecture** - Separate frameworks
- [ ] **Plugin system** - Third-party extensions
- [ ] **Theming support** - Custom UI themes
- [ ] **Preferences sync** - CloudKit sync
- [ ] **Export/import settings** - Settings profiles

### Performance
- [ ] **Incremental OCR** - Process while selecting
- [ ] **GPU acceleration** - Metal for image processing
- [ ] **Background processing** - Queue multiple captures
- [ ] **Caching layer** - Cache OCR results temporarily
- [ ] **Parallel OCR** - Multi-threaded processing

### Security
- [ ] **Sandboxing** - Enable App Sandbox if possible
- [ ] **Keychain encryption** - Additional license encryption
- [ ] **Certificate pinning** - Pin Gumroad certificates
- [ ] **Secure wipe** - Overwrite temp files
- [ ] **Privacy mode** - Don't save history for sensitive captures

## Known Issues

### To Fix
- [ ] **Hotkey conflicts** - Better detection and handling
- [ ] **Multi-space support** - Works across Spaces?
- [ ] **Full-screen app capture** - Permission issues?
- [ ] **HDR display compatibility** - Test on HDR Macs
- [ ] **External display orientation** - Portrait mode support
- [ ] **Accessibility permission** - Fallback if Carbon Events fail

### Limitations
- Requires macOS 13+ for ScreenCaptureKit (documented)
- Single-seat license only (by design)
- No App Sandbox (requires broad permissions)
- Global hotkey may conflict with other apps

## Nice-to-Haves

### UI/UX
- [ ] **Dark mode optimization** - Refine dark theme
- [ ] **Menu bar icon states** - Animate during capture
- [ ] **Capture preview** - Show captured image before OCR
- [ ] **Undo last capture** - Restore previous clipboard
- [ ] **Capture annotations** - Draw on captures before OCR
- [ ] **Region presets** - Save common capture regions
- [ ] **Follow cursor** - Region follows mouse movement

### Integrations
- [ ] **Raycast extension** - Quick capture from Raycast
- [ ] **Alfred workflow** - Alfred integration
- [ ] **BetterTouchTool** - Custom gesture triggers
- [ ] **Keyboard Maestro** - Macro integration
- [ ] **Hazel rules** - Automated OCR of downloads
- [ ] **DEVONthink** - Send captures to DEVONthink
- [ ] **Notion/Obsidian** - Direct export to notes apps

## Research & Exploration

### Technologies
- [ ] **Metal for OCR** - Faster than Vision?
- [ ] **Core ML models** - Custom trained OCR models
- [ ] **Live Text API** - macOS 12+ Live Text integration
- [ ] **Translation API** - Inline translation of OCR'd text
- [ ] **Natural Language** - NLP analysis of captures

### Platform
- [ ] **Mac App Store** - Sandboxed version
- [ ] **SetApp distribution** - Alternative distribution
- [ ] **Enterprise licensing** - Volume licensing
- [ ] **Education pricing** - Student/teacher discounts

## Maintenance

### Regular Tasks
- [ ] **Update dependencies** - Keep Sparkle current
- [ ] **macOS compatibility** - Test new macOS versions
- [ ] **Security updates** - CVE monitoring
- [ ] **Performance regression** - Benchmark each release
- [ ] **User feedback review** - Triage feature requests

### Documentation
- [ ] **Keep README current** - Update with new features
- [ ] **Architecture updates** - Reflect changes in ARCHITECTURE.md
- [ ] **API documentation** - Swift DocC
- [ ] **Tutorial videos** - Update for new features

---

## Priority Matrix

### Must Have (V1.0)
1. Stable capture and OCR
2. License verification
3. Code signing and notarization
4. Basic documentation

### Should Have (V1.x)
1. Hotkey recorder UI
2. Better error handling
3. Performance optimizations
4. Unit tests

### Could Have (V2.0)
1. QR/Barcode reading
2. Text-to-speech
3. History feature
4. CLI interface

### Won't Have (Future)
1. Cloud sync
2. Team features
3. Browser extension
4. iOS app

---

**Last Updated**: 2025-10-23

Use this as a living document. Check off items as completed and add new ideas as they come up.
