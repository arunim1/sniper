# SnipIt Quick Start Guide

## What You Have

A complete macOS menu bar OCR application with:

- ✅ 14 Swift source files implementing all core features
- ✅ Global hotkey support (⌘⇧2)
- ✅ Screen capture with ScreenCaptureKit
- ✅ Vision-based OCR
- ✅ Clipboard integration
- ✅ SwiftUI preferences
- ✅ Gumroad licensing
- ✅ Onboarding flow
- ✅ HUD notifications
- ✅ Complete documentation

## Next Steps to Run

### Option 1: Build with Xcode (Recommended)

1. **Create Xcode Project**:
   ```bash
   cd /Users/arunim/Documents/github/sniper
   swift package generate-xcodeproj
   open SnipIt.xcodeproj
   ```

2. **Configure Project**:
   - Select SnipIt target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Change bundle identifier if needed: `com.snipit.SnipIt`

3. **Add Info.plist**:
   - In Xcode, go to target settings
   - Under "Info" tab, add custom Info.plist location: `Sources/Info.plist`

4. **Add Entitlements**:
   - Under "Signing & Capabilities"
   - Click "+ Capability" if needed
   - Use entitlements file: `Sources/SnipIt.entitlements`

5. **Build and Run**:
   - Press ⌘R to build and run
   - Grant Screen Recording permission when prompted
   - Test capture with ⌘⇧2

### Option 2: Build with SPM

```bash
cd /Users/arunim/Documents/github/sniper
swift build -c release
.build/release/SnipIt
```

**Note**: SPM builds won't have proper Info.plist or entitlements without additional setup. Use Xcode for full functionality.

## Testing the App

### 1. First Launch
- App icon should appear in menu bar
- Onboarding window should open
- Follow steps to grant Screen Recording permission

### 2. Test Capture
- Press ⌘⇧2 (or click menu bar icon → Capture)
- Click and drag to select a region with text
- Text should be copied to clipboard
- HUD should show "Copied X characters"

### 3. Test Preferences
- Click menu bar icon → Preferences
- Verify all tabs load correctly
- Try changing settings

### 4. Test License (Optional)
- Click menu bar icon → Enter License
- Enter a test license key
- Should show verification (will fail without real Gumroad product ID)

## Common Issues

### "App is damaged and can't be opened"
This is macOS Gatekeeper. You need to:
1. Sign the app with Developer ID
2. Or, for development: Right-click → Open, then click "Open" in dialog

### Screen Recording Permission Not Working
1. Go to System Settings → Privacy & Security → Screen Recording
2. Enable SnipIt
3. Restart the app

### Hotkey Not Registering
- Check Console.app for error messages
- Verify no conflicts with other apps
- Try a different hotkey combination

## Configuration Needed

### 1. Gumroad Product ID
Edit `Sources/LicenseService.swift`:
```swift
private let productID = "YOUR_GUMROAD_PRODUCT_ID"
```

### 2. Sparkle Updates (Optional)
1. Generate keys: `./bin/generate_keys` (from Sparkle)
2. Edit `Sources/Info.plist`:
   - Set `SUFeedURL` to your appcast URL
   - Set `SUPublicEDKey` to your public key

### 3. Bundle ID (If Needed)
Edit `Sources/Info.plist` and update:
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.SnipIt</string>
```

## Project Structure

```
Sources/
├── main.swift                          # Entry point
├── AppDelegate.swift                   # App coordinator
├── MenuBarController.swift             # Menu bar UI
├── HotkeyService.swift                # Global hotkey (⌘⇧2)
├── SelectionOverlay.swift             # Capture selection UI
├── CaptureController.swift            # Screen capture orchestration
├── OcrService.swift                   # Vision OCR
├── ClipboardService.swift             # Clipboard operations
├── HUDController.swift                # Toast notifications
├── PreferencesStore.swift             # Settings persistence
├── PreferencesWindowController.swift   # Settings UI
├── LicenseService.swift               # Gumroad licensing
├── LicenseWindowController.swift      # License UI
└── OnboardingWindowController.swift   # First-run flow
```

## Architecture Highlights

### Key Features Implemented

1. **HotkeyService**: Uses Carbon `RegisterEventHotKey` (no Accessibility permission needed)
2. **CaptureController**: ScreenCaptureKit with fallback for older macOS
3. **OcrService**: Vision framework with post-processing for clean text
4. **LicenseService**: Gumroad API with Keychain storage and 30-day grace period
5. **SelectionOverlay**: Full-screen overlay with rubber-band selection

### Data Flow

```
Hotkey Press (⌘⇧2)
  → Check License
  → Check Permission
  → Show Selection Overlay
  → Capture Region (ScreenCaptureKit)
  → OCR Text (Vision)
  → Copy to Clipboard
  → Show HUD
```

## Customization

### Change Default Hotkey
Edit `Sources/PreferencesStore.swift`:
```swift
// Default: ⌘⇧2
captureHotkeyKeyCode = UInt32(kVK_ANSI_2)
captureHotkeyModifiers = UInt32(cmdKey | shiftKey)
```

### Adjust OCR Settings
Edit `Sources/PreferencesStore.swift`:
```swift
ocrLanguages = ["en-US", "es-ES", "fr-FR"]  // Add languages
recognitionLevel = "accurate"  // or "fast"
```

### Customize HUD Duration
Edit `Sources/HUDController.swift`:
```swift
func show(message: String, duration: TimeInterval = 2.0)  // Change default
```

## Development Tips

### Debugging
- Enable detailed logging in Xcode
- Check Console.app for system messages
- Use Instruments for performance profiling

### Testing Permissions
- Reset TCC database to test permission flow:
  ```bash
  tccutil reset ScreenCapture com.snipit.SnipIt
  ```

### Building for Distribution
See [README.md](README.md) section on code signing and notarization.

## What's NOT Implemented Yet

These are marked for V2:
- [ ] QR/Barcode reading
- [ ] Text-to-speech
- [ ] Capture history
- [ ] Table detection with CSV export
- [ ] CLI interface
- [ ] AppleScript/URL scheme automation
- [ ] Full hotkey recorder UI (currently shows current hotkey only)
- [ ] Launch at login implementation (requires SMAppService)

## Getting Help

1. Read [README.md](README.md) for full documentation
2. Read [ARCHITECTURE.md](ARCHITECTURE.md) for system design
3. Check source code comments
4. Review requirements in project prompt

## Building for Release

1. **Archive in Xcode**:
   - Product → Archive
   - Organizer → Distribute App → Copy App

2. **Sign and Notarize**:
   ```bash
   # Sign
   codesign --deep --force --options runtime \
     --sign "Developer ID Application: Your Name" \
     --entitlements Sources/SnipIt.entitlements \
     SnipIt.app

   # Create DMG
   hdiutil create -volname "SnipIt" -srcfolder SnipIt.app \
     -ov -format UDZO SnipIt.dmg

   # Notarize
   xcrun notarytool submit SnipIt.dmg \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait

   # Staple
   xcrun stapler staple SnipIt.dmg
   ```

3. **Test**:
   - Install on clean Mac
   - Verify Gatekeeper doesn't block
   - Test all features

## Success Checklist

- [ ] App builds without errors
- [ ] Menu bar icon appears
- [ ] Onboarding shows on first launch
- [ ] Screen Recording permission can be granted
- [ ] ⌘⇧2 triggers capture overlay
- [ ] Selection captures and OCRs text
- [ ] Text appears on clipboard
- [ ] HUD shows confirmation
- [ ] Preferences window opens and saves settings
- [ ] License window opens (even if verification fails)

## Next Actions

1. **Generate Xcode Project**: `make xcode` or `swift package generate-xcodeproj`
2. **Open in Xcode**: Configure signing with your team
3. **Build and Run**: Test core functionality
4. **Configure Gumroad**: Add your product ID
5. **Test End-to-End**: Complete capture flow
6. **Sign and Distribute**: Follow release process

---

**You're ready to build and test SnipIt!** 🎉

All core functionality is implemented. The app should work immediately once you:
1. Generate the Xcode project
2. Configure code signing
3. Build and run

For questions about implementation details, check the source code comments or architecture documentation.
