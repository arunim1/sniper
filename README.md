# Sniper - macOS OCR Menu Bar App

A privacy-respecting macOS menu-bar utility to OCR any on-screen region with a single global shortcut (⌘⇧2) and copy the text to clipboard instantly.

## Quick Installation

```bash
# Clone the repository
git clone https://github.com/arunim1/sniper.git
cd sniper

# Build the app
chmod +x build_app.sh
./build_app.sh

# Install to Applications folder
cp -r Sniper.app /Applications/

# Set up auto-launch on login
mkdir -p ~/Library/LaunchAgents
cp com.sniper.Sniper.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.sniper.Sniper.plist
```

The app will now run in the background and launch automatically on login!

## Features

- **Fast OCR**: Capture and recognize text from any region of your screen
- **Global Hotkey**: Default ⌘⇧2 (customizable)
- **Privacy First**: All OCR processing happens locally on your device
- **Multi-Display Support**: Works across multiple monitors
- **Language Support**: Configurable OCR languages
- **Offline**: No internet required for OCR functionality
- **Gumroad Licensing**: One-time purchase with offline grace period

## Requirements

- macOS 13.0 or later (optimized for Apple Silicon)
- Screen Recording permission

## Architecture

### Core Components

1. **AppDelegate**: Main application coordinator
2. **MenuBarController**: Manages menu bar icon and menu
3. **HotkeyService**: Handles global hotkey registration (Carbon API)
4. **SelectionOverlay**: Rubber-band selection UI
5. **CaptureController**: Screen capture using ScreenCaptureKit
6. **OcrService**: Text recognition using Vision framework
7. **ClipboardService**: Clipboard management
8. **LicenseService**: Gumroad license verification and caching
9. **PreferencesStore**: User settings persistence
10. **HUDController**: Toast notifications

### Technology Stack

- **Language**: Swift 5.10
- **UI**: AppKit + SwiftUI (for preferences)
- **Screen Capture**: ScreenCaptureKit (macOS 13+)
- **OCR**: Vision framework (`VNRecognizeTextRequest`)
- **Hotkeys**: Carbon `RegisterEventHotKey`
- **Updates**: Sparkle 2
- **Package Manager**: Swift Package Manager

## Building

### Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### Using Swift Package Manager

This project uses Swift Package Manager. To build:

```bash
# Resolve dependencies
swift package resolve

# Build the project
swift build -c release

# Or use Xcode
open Package.swift
```

### Creating an Xcode Project

To create a proper Xcode project for development:

1. Create a new macOS App project in Xcode
2. Copy all `.swift` files from `Sources/` to the project
3. Add `Package.swift` dependencies manually or use SPM integration
4. Copy `Info.plist` and `Sniper.entitlements` to the project
5. Configure build settings:
   - Minimum Deployment: macOS 13.0
   - Swift Language Version: 5.10
   - Enable Hardened Runtime
   - Code Sign with your Developer ID

### Build Settings

Required entitlements:
- Network Client (for license verification)
- Screen Recording (requested at runtime via TCC)

Required Info.plist keys:
- `NSScreenCaptureDescription`: Explains why screen recording is needed
- `LSUIElement`: YES (runs as menu bar app without dock icon)

## Configuration

### Gumroad Integration

Update the following in [LicenseService.swift](Sources/LicenseService.swift):

```swift
private let productID = "YOUR_GUMROAD_PRODUCT_ID"
```

### Sparkle Updates

1. Generate EdDSA key pair:
```bash
./bin/generate_keys
```

2. Update [Info.plist](Sources/Info.plist):
```xml
<key>SUFeedURL</key>
<string>https://your-domain.com/appcast.xml</string>
<key>SUPublicEDKey</key>
<string>YOUR_SPARKLE_PUBLIC_KEY</string>
```

## Code Signing & Notarization

### Development

```bash
# Sign the app
codesign --deep --force --options runtime \
  --sign "Developer ID Application: Your Name" \
  --entitlements Sniper.entitlements \
  Sniper.app
```

### Distribution

```bash
# Create DMG
hdiutil create -volname "Sniper" -srcfolder Sniper.app -ov -format UDZO Sniper.dmg

# Sign DMG
codesign --sign "Developer ID Application: Your Name" Sniper.dmg

# Notarize
xcrun notarytool submit Sniper.dmg \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple ticket
xcrun stapler staple Sniper.dmg
```

## Usage

### First Run

1. Launch Sniper
2. Complete onboarding
3. Grant Screen Recording permission in System Settings
4. Enter license key (or purchase from Gumroad)

### Capturing Text

1. Press ⌘⇧2 (or your custom hotkey)
2. Click and drag to select the region
3. Text is automatically recognized and copied to clipboard
4. HUD shows confirmation with character count

### Preferences

Access from menu bar icon:
- **General**: Launch at login, HUD settings, clipboard behavior
- **Shortcut**: Customize hotkey (future enhancement)
- **OCR**: Language selection, recognition speed
- **License**: Activation status, deactivation

## Project Structure

```
sniper/
├── Package.swift                 # SPM configuration
├── README.md                     # This file
├── Sources/
│   ├── main.swift               # Entry point
│   ├── AppDelegate.swift        # App coordinator
│   ├── MenuBarController.swift  # Menu bar management
│   ├── HotkeyService.swift      # Global hotkey handling
│   ├── SelectionOverlay.swift   # Capture UI
│   ├── CaptureController.swift  # Screen capture
│   ├── OcrService.swift         # Vision OCR
│   ├── ClipboardService.swift   # Clipboard operations
│   ├── HUDController.swift      # Toast notifications
│   ├── LicenseService.swift     # Gumroad licensing
│   ├── LicenseWindowController.swift
│   ├── PreferencesStore.swift   # Settings persistence
│   ├── PreferencesWindowController.swift
│   ├── OnboardingWindowController.swift
│   ├── Info.plist              # App metadata
│   └── Sniper.entitlements     # Security entitlements
└── Resources/                   # Assets (if any)
```

## Development Roadmap

### V1 (Current)
- [x] Global hotkey capture
- [x] Rubber-band selection
- [x] ScreenCaptureKit integration
- [x] Vision OCR
- [x] Clipboard copy with HUD
- [x] Preferences window
- [x] Gumroad licensing
- [x] Onboarding flow
- [ ] Final testing and polish
- [ ] Code signing and notarization
- [ ] Sparkle update feed

### V2 (Future)
- [ ] QR/Barcode reader
- [ ] Text-to-speech
- [ ] Capture history
- [ ] Table detection with CSV export
- [ ] CLI interface
- [ ] AppleScript/URL scheme automation

## Testing

### Permission Testing

Test on a clean macOS installation:
1. First launch should show onboarding
2. Permission prompt should appear for Screen Recording
3. After granting, test capture should work
4. Deny and re-grant scenarios

### OCR Testing

Test with various content:
- Clear text (slides, documents)
- Small text (UI elements)
- Code snippets
- Multiple languages
- Rotated text
- Low contrast scenarios

### Performance Benchmarks

Target metrics:
- Capture latency: < 500ms P95 on Apple Silicon
- Memory: < 100MB RSS steady-state
- CPU: No persistent usage when idle

## Troubleshooting

### "Permission Denied" errors

1. Go to System Settings > Privacy & Security > Screen Recording
2. Ensure Sniper is enabled
3. Restart Sniper

### Hotkey not working

1. Check for conflicts with other apps
2. Try registering a different hotkey in Preferences
3. Ensure Sniper is running (menu bar icon visible)

### OCR accuracy issues

1. Ensure good image quality (high resolution)
2. Try "Accurate" recognition level in preferences
3. Select appropriate language for content
4. Avoid very small text or poor contrast

## License

This is the source code for Sniper, a commercial application.
License key required from Gumroad for use.

## Privacy Policy

Sniper is designed with privacy as a priority:
- All OCR processing happens locally on your device
- No screenshots or text data is sent to external servers
- Network access is only used for license verification
- License checks can be performed offline with grace period
- No analytics or telemetry by default

## Support

For issues or feature requests, contact support or file an issue.

---

Built with Swift, AppKit, and Vision framework for macOS.
