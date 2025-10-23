# SnipIt Architecture

## Overview

SnipIt is a macOS menu bar application that provides instant OCR capabilities for screen regions. The architecture emphasizes privacy, performance, and offline functionality.

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     User Interface                       │
├─────────────────────────────────────────────────────────┤
│  MenuBar  │  Overlay  │  HUD  │  Preferences  │ Onboard │
└────┬──────┴─────┬─────┴───┬───┴──────┬────────┴────┬────┘
     │            │         │          │             │
┌────▼────────────▼─────────▼──────────▼─────────────▼────┐
│                  AppDelegate (Coordinator)               │
└────┬────────┬──────────┬────────────┬──────────┬────────┘
     │        │          │            │          │
┌────▼────┐ ┌▼──────┐ ┌─▼────────┐ ┌─▼──────┐ ┌▼────────┐
│ Hotkey  │ │Capture│ │   OCR    │ │License│ │Clipboard│
│ Service │ │Control│ │ Service  │ │Service│ │ Service │
└────┬────┘ └┬──────┘ └─┬────────┘ └─┬──────┘ └┬────────┘
     │       │          │             │         │
     │    ┌──▼──────┐ ┌─▼─────────┐  │         │
     │    │ Screen  │ │  Vision   │  │         │
     │    │Capture  │ │ Framework │  │         │
     │    │   Kit   │ └───────────┘  │         │
     │    └─────────┘                │         │
     │                                │         │
┌────▼────────────────────────────────▼─────────▼────────┐
│               Foundation & System APIs                  │
│  Carbon Events │ NSPasteboard │ Keychain │ URLSession  │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### 1. AppDelegate

**Responsibility**: Application lifecycle and service coordination

**Key Functions**:
- Initialize all services
- Coordinate hotkey triggers
- Handle first-run onboarding
- Manage license verification on launch

**Dependencies**: All services

### 2. MenuBarController

**Responsibility**: Menu bar UI and user interactions

**Key Functions**:
- Create and manage status item
- Build menu with dynamic items
- Show preferences/license windows
- Handle alerts and permissions

**Dependencies**: CaptureController, LicenseService, PreferencesStore

### 3. HotkeyService

**Responsibility**: Global hotkey registration and handling

**Implementation**:
- Uses Carbon `RegisterEventHotKey` API (no Accessibility permission needed)
- Singleton pattern for event callback
- Conflict detection

**Key Functions**:
- Register hotkey with OS
- Invoke callback on hotkey press
- Unregister and update hotkeys

**Dependencies**: PreferencesStore

### 4. SelectionOverlay

**Responsibility**: Interactive screen region selection

**Implementation**:
- Borderless NSWindow at screen saver level
- Custom NSView with mouse tracking
- Rubber-band selection rectangle

**Key Functions**:
- Show crosshair cursor
- Track mouse drag
- Calculate selection rectangle in screen coordinates
- Handle escape key cancellation

**Dependencies**: None (pure UI)

### 5. CaptureController

**Responsibility**: Screen capture orchestration

**Implementation**:
- ScreenCaptureKit for macOS 13+
- Fallback to CGWindowListCreateImage for older versions
- Multi-display support

**Key Functions**:
- Show selection overlay
- Capture screen region
- Invoke OCR service
- Handle results and errors

**Dependencies**: SelectionOverlay, OcrService, ClipboardService

### 6. OcrService

**Responsibility**: Text recognition from images

**Implementation**:
- Vision `VNRecognizeTextRequest`
- Configurable recognition level (fast/accurate)
- Multi-language support

**Key Functions**:
- Perform OCR on CGImage
- Post-process text (line breaks, hyphenation)
- Group observations into lines
- Sort by spatial position

**Dependencies**: PreferencesStore

**Performance**:
- Runs on background queue
- Async/await interface
- Target: < 500ms P95 for typical regions

### 7. ClipboardService

**Responsibility**: Clipboard operations

**Implementation**:
- NSPasteboard wrapper
- Append or replace modes

**Key Functions**:
- Copy text to clipboard
- Append with double line break
- Get current clipboard text

**Dependencies**: PreferencesStore

### 8. HUDController

**Responsibility**: Toast notifications

**Implementation**:
- NSPanel with NSVisualEffectView
- Floating window level
- Auto-hide after duration

**Key Functions**:
- Show success message with character count
- Auto-hide after delay
- Respect system dark mode

**Dependencies**: None

### 9. LicenseService

**Responsibility**: License verification and management

**Implementation**:
- Gumroad API integration
- Keychain storage for license key
- Offline grace period (30 days)
- Device binding via machine UUID

**Key Functions**:
- Verify license with Gumroad
- Cache validation results
- Check grace period
- Handle refunded/disputed states

**Security**:
- HTTPS only
- License stored in Keychain
- Device hash for single-seat enforcement

**Dependencies**: PreferencesStore, Keychain

### 10. PreferencesStore

**Responsibility**: Settings persistence

**Implementation**:
- UserDefaults wrapper
- Published properties for SwiftUI
- Default values on first run

**Settings**:
- Hotkey configuration
- OCR languages and level
- Line break preservation
- Clipboard append mode
- HUD display
- Launch at login

**Dependencies**: None

### 11. PreferencesWindowController

**Responsibility**: Settings UI

**Implementation**:
- SwiftUI views hosted in NSWindow
- Tabbed interface
- Two-way binding with PreferencesStore

**Tabs**:
- General: System integration
- Shortcut: Hotkey configuration
- OCR: Recognition settings
- License: Activation info

**Dependencies**: PreferencesStore

### 12. LicenseWindowController

**Responsibility**: License activation UI

**Implementation**:
- SwiftUI modal window
- License key input
- Async verification
- Status display

**States**:
- Entry form
- Verifying (with progress)
- Success
- Error (with message)

**Dependencies**: LicenseService

### 13. OnboardingWindowController

**Responsibility**: First-run experience

**Implementation**:
- SwiftUI multi-page flow
- Permission checking
- System Settings deep link

**Pages**:
1. Welcome
2. How to use
3. Privacy explanation
4. Permission grant

**Dependencies**: PreferencesStore, ScreenCaptureKit (for permission check)

## Data Flow

### Capture Flow

```
User presses ⌘⇧2
    ↓
HotkeyService invokes callback
    ↓
AppDelegate.handleCaptureHotkey()
    ↓
Check license (LicenseService)
    ↓
Check permission (ScreenCaptureKit)
    ↓
CaptureController.startCapture()
    ↓
Show SelectionOverlay
    ↓
User drags selection
    ↓
SelectionOverlay returns CGRect
    ↓
CaptureController.captureScreen(rect)
    ↓
ScreenCaptureKit captures region → CGImage
    ↓
OcrService.recognizeText(image)
    ↓
Vision processes → observations
    ↓
OcrService.processObservations()
    ↓
Post-process text
    ↓
ClipboardService.copyToClipboard(text)
    ↓
HUDController.show(message)
    ↓
User sees confirmation
```

### License Verification Flow

```
App Launch
    ↓
LicenseService.verifyLicenseIfNeeded()
    ↓
Check last verification date
    ↓
If > 7 days old:
    ↓
Gumroad API POST /licenses/verify
    ↓
Parse response
    ↓
If success:
    - Store in Keychain
    - Update last verification date
    - Cache status
    ↓
If failure and within grace period:
    - Allow usage
    - Show warning
    ↓
If failure and past grace:
    - Block captures
    - Show license prompt
```

## Security Considerations

### Permissions (TCC)

- **Screen Recording**: Required for ScreenCaptureKit
  - Requested via TCC on first capture attempt
  - Guided flow in onboarding
  - Deep link to System Settings

- **Network**: For license verification only
  - Not required for core OCR functionality
  - Offline grace period

- **Accessibility**: NOT required
  - Hotkeys use Carbon Events instead of CGEvent tap

### Data Protection

- **Screen Captures**: Temporary, deleted after OCR
- **License Key**: Stored in Keychain (encrypted)
- **Device Hash**: Used for device binding only
- **No Telemetry**: Zero data collection by default

### Code Signing

- Developer ID Application certificate
- Hardened Runtime enabled
- Notarization required for Gatekeeper

## Performance

### Optimization Strategies

1. **OCR Performance**:
   - Background queue execution
   - Recognition level setting (fast/accurate)
   - Bounded region capture

2. **Memory Management**:
   - CGImage lifecycle management
   - Overlay window reuse
   - Service singletons

3. **Startup Time**:
   - Lazy initialization where possible
   - Async license verification
   - Menu bar only (no dock)

### Benchmarks (Target)

- Capture latency: < 500ms P95 (M-series)
- Memory RSS: < 100MB steady-state
- CPU idle: < 5%
- Binary size: < 20MB

## Testing Strategy

### Unit Tests
- OcrService text post-processing
- LicenseService grace period logic
- PreferencesStore defaults

### Integration Tests
- Capture → OCR pipeline
- Multi-display scenarios
- Permission flows

### Manual Tests
- TCC permission grant/revoke
- Hotkey conflicts
- Language variants
- Scaling factors (1×, 2×, 3×)

## Future Enhancements

### V2 Backlog
- QR/Barcode detection (Vision VNDetectBarcodesRequest)
- Text-to-speech (AVSpeechSynthesizer)
- Capture history (CoreData or SQLite)
- Table detection (VNDetectDocumentSegmentationRequest)
- CLI interface (ArgumentParser)
- URL scheme automation

### Architecture Impact
- History: Add CoreData stack
- TTS: Add AVFoundation integration
- CLI: Add ArgumentParser, separate executable target

## Dependencies

### Swift Packages
- **Sparkle 2**: Auto-updates (EdDSA signing)

### System Frameworks
- **AppKit**: UI foundation
- **SwiftUI**: Preferences/onboarding
- **ScreenCaptureKit**: Screen capture (macOS 13+)
- **Vision**: OCR
- **Security**: Keychain
- **Foundation**: Networking, persistence
- **Carbon**: Hotkey events
- **IOKit**: Device UUID

### External APIs
- **Gumroad**: License verification

## Build & Distribution

### Build System
- Swift Package Manager
- Makefile for common tasks
- Xcode project for development

### Distribution Channels
1. **Direct Download**: DMG via website
2. **Future**: Mac App Store (requires receipt validation instead of Gumroad)

### Update Mechanism
- Sparkle 2 with EdDSA signatures
- Appcast XML feed
- Delta updates for efficiency

---

Last updated: 2025-10-23
