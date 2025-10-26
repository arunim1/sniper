# Architecture

## Overview

Sniper is a macOS menu bar app that performs OCR on screen regions.

## Components

### Core Services
- **AppDelegate**: App lifecycle and coordination
- **HotkeyService**: Global hotkey registration (Carbon Events)
- **CaptureController**: Orchestrates capture flow
- **SelectionOverlay**: Rubber-band selection UI
- **OcrService**: Vision framework OCR
- **ClipboardService**: Clipboard operations
- **HUDController**: Toast notifications

### UI
- **MenuBarController**: Status item and menu
- **PreferencesWindowController**: Settings (SwiftUI)
- **OnboardingWindowController**: First-run flow (SwiftUI)
- **LicenseWindowController**: License activation (SwiftUI)

### Data
- **PreferencesStore**: UserDefaults wrapper
- **LicenseService**: Gumroad integration + Keychain

## Data Flow

```
User presses ⌘⇧2
  → HotkeyService callback
  → AppDelegate.handleCapture()
  → Check permissions
  → CaptureController.startCapture()
  → Show SelectionOverlay
  → User selects region
  → Capture screen (ScreenCaptureKit)
  → OcrService.recognize(image)
  → ClipboardService.copy(text)
  → HUDController.show(message)
```

## Technologies

- Swift 5.10
- AppKit (menu bar, windows)
- SwiftUI (preferences, onboarding)
- ScreenCaptureKit (screen capture)
- Vision (OCR)
- Carbon Events (hotkeys)
- Keychain (license storage)

## Permissions

- **Screen Recording**: Required for capture (TCC prompt)
- **Network**: Optional, for license verification

## Build

Uses Swift Package Manager with minimal dependencies.
